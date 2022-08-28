//
//  TodoService.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 14.08.2022.
//

import Foundation
import CocoaLumberjack
import Helpers

protocol TodoServiceProtocol {
    var threadSafeTodoItems: [TodoItem] { get }

    func add(_ todoItem: TodoItem)
    func update(_ todoItem: TodoItem)
    func delete(_ todoItemID: String)
    func load()

    func assignDelegate(_ delegate: TodoServiceDelegate)
}

protocol TodoServiceDelegate: AnyObject {
    func todoItemsChanged()
    func requestStarted()
    func requestEnded()
}

final class TodoService: TodoServiceProtocol {
    var threadSafeTodoItems: [TodoItem] {
        todoServiceQueue.sync {
            return todoItems
        }
    }

    private let todoServiceQueue = DispatchQueue(label: Constants.queueLabel, attributes: [.concurrent])
    private let networkService: NetworkServiceProtocol
    private var fileCacheService: FileCacheServiceProtocol
    private var retryNumber: Int = .zero

    private var todoItems: [TodoItem] = [] {
        didSet { callDelegate() }
    }

    private weak var delegate: TodoServiceDelegate?

    init(_ fileCacheService: FileCacheServiceProtocol, _ networkService: NetworkServiceProtocol) {
        self.fileCacheService = fileCacheService
        self.networkService = networkService
        load()
    }

    func assignDelegate(_ delegate: TodoServiceDelegate) {
        self.delegate = delegate
    }
}

// MARK: Main actions
extension TodoService {
    func add(_ todoItem: TodoItem) {
        addToCurrentList(todoItem)
        addToServices(todoItem)
    }

    func update(_ todoItem: TodoItem) {
        updateIntoCurrentList(todoItem)
        updateIntoServices(todoItem)
    }

    func delete(_ todoItemID: String) {
        deleteFromCurrentList(todoItemID)
        deleteFromServices(todoItemID)
    }

    func load() {
        delegate?.requestStarted()
        fileCacheService.load() { [weak self] result in
            switch result {
            case .success(let cacheItems):
                self?.loadToCurrentList(cacheItems)
                self?.networkService.fetchTodoItems { [weak self] result in
                    self?.delegate?.requestEnded()

                    switch result {
                    case .success((_, let revision)):
                        self?.syncIfNeeded(revision)
                    case .failure(let error):
                        DDLogInfo(error)
                        // NB: Уведомить, что не прошло
                    }
                }
            case .failure(let error):
                DDLogInfo(error)

                self?.networkService.fetchTodoItems { [weak self] result in
                    self?.delegate?.requestEnded()

                    switch result {
                    case .success((let todoItems, let revision)):
                        self?.loadToCurrentList(todoItems)
                        self?.fileCacheService.revision = revision
                        self?.fileCacheService.reloadCache(with: todoItems)
                    case .failure(let error):
                        DDLogInfo(error)
                        // NB: Уведомить, что не прошло
                    }
                }
            }
        }
    }
}

// MARK: TodoItems model actions
extension TodoService {
    private func addToCurrentList(_ todoItem: TodoItem) {
        todoServiceQueue.async(flags: .barrier) { [weak self] in
            guard !(self?.todoItems.contains(where: { $0.id == todoItem.id}) ?? true) else { return }
            self?.todoItems.append(todoItem)
        }
    }

    private func updateIntoCurrentList(_ todoItem: TodoItem) {
        todoServiceQueue.async(flags: .barrier) { [weak self] in
            guard let index = self?.todoItems.firstIndex(where: { $0.id == todoItem.id }) else { return }
            self?.todoItems[index] = todoItem
        }
    }

    private func deleteFromCurrentList(_ todoItemID: String) {
        todoServiceQueue.async(flags: .barrier) { [weak self] in
            guard let index = self?.todoItems.firstIndex(where: { $0.id == todoItemID }) else { return }
            self?.todoItems.remove(at: index)
        }
    }

    private func loadToCurrentList(_ todoItems: [TodoItem]) {
        self.todoServiceQueue.async(flags: .barrier) { [weak self] in
            self?.todoItems = todoItems
        }
    }
}

// MARK: Services actions
extension TodoService {
    private func addToServices(_ todoItem: TodoItem) {
        delegate?.requestStarted()
        networkService.add(todoItem, lastKnownRevision: fileCacheService.revision) { [weak self] result in
            self?.delegate?.requestEnded()

            switch result {
            case .success(let revision):
                self?.fileCacheService.revision = revision
                self?.fileCacheService.add(todoItem) { [weak self] cacheResult in
                    self?.handleVoidResult(cacheResult)
                }
                self?.retryNumber = .zero
            case .failure(let error):
                self?.fileCacheService.add(todoItem.asDirty) { [weak self] cacheResult in
                    self?.handleVoidResult(cacheResult)
                }

                self?.executeWithExponentialRetry() { [weak self] in
                    self?.addToServices(todoItem)
                }

                DDLogInfo(error)
            }
        }
    }

    private func updateIntoServices(_ todoItem: TodoItem) {
        delegate?.requestStarted()
        networkService.update(todoItem, lastKnownRevision: fileCacheService.revision) { [weak self] result in
            self?.delegate?.requestEnded()

            switch result {
            case .success(let revision):
                self?.fileCacheService.revision = revision
                self?.fileCacheService.update(todoItem) { cacheResult in
                    self?.handleVoidResult(cacheResult)
                }
            case .failure(let error):
                self?.fileCacheService.update(todoItem.asDirty) { cacheResult in
                    self?.handleVoidResult(cacheResult)
                }

                self?.executeWithExponentialRetry() { [weak self] in
                    self?.updateIntoServices(todoItem)
                }

                DDLogInfo(error)
            }
        }
    }

    private func deleteFromServices(_ todoItemID: String) {
        delegate?.requestStarted()

        fileCacheService.delete(todoItemID: todoItemID) { [weak self] cacheResult in
            self?.handleVoidResult(cacheResult)
        }

        networkService.delete(todoItemID: todoItemID, lastKnownRevision: fileCacheService.revision) { [weak self] result in
            self?.delegate?.requestEnded()

            switch result {
            case .success(let revision):
                self?.fileCacheService.revision = revision
            case .failure(let error):
                self?.fileCacheService.isTombstonesExist = true

                self?.executeWithExponentialRetry() { [weak self] in
                    self?.deleteFromServices(todoItemID)
                }

                DDLogInfo(error)
            }
        }
    }
}

// MARK: Sync methods
extension TodoService {
    private func syncIfNeeded(_ revision: Int) {
        guard fileCacheService.isDirtiesExist
                || fileCacheService.isTombstonesExist
                || revision != fileCacheService.revision else {
            return
        }
        sync()
    }

    private func sync() {
        delegate?.requestStarted()
        networkService.sync(threadSafeTodoItems) { [weak self] result in
            self?.delegate?.requestEnded()
            switch result {
            case .success((let todoItems, let revision)):
                self?.loadToCurrentList(todoItems)
                self?.fileCacheService.revision = revision
                self?.fileCacheService.isTombstonesExist = false
                self?.fileCacheService.reloadCache(with: todoItems)
            case .failure(let error):
                self?.executeWithExponentialRetry {
                    self?.sync()
                }
                DDLogInfo(error)
            }
        }
    }
}

// MARK: Support methods
extension TodoService {
    func callDelegate() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.todoItemsChanged()
        }
    }

    func handleVoidResult(_ result: VoidResult) {
        switch result {
        case .success:
            break
        case .failure(let error):
            DDLogInfo(error)
            // NB: Обработать
        }
    }

    private func executeWithExponentialRetry(closure: @escaping () -> Void) {
        func getDelay() -> Int {
            let exponentialDelay = Constants.minDelay * pow(Constants.factor, Double(retryNumber))
            let delay = min(exponentialDelay, Constants.maxDelay)
            let resultDelay = delay * Double.random(in: (Constants.oneHundredPercent - Constants.jitter)...(Constants.oneHundredPercent + Constants.jitter))
            return Int(resultDelay.rounded())
        }

        let delay = getDelay()
        retryNumber += 1
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + .milliseconds(delay),
            execute: closure)
    }
}

// MARK: Constants
extension TodoService {
    private enum Constants {
        static let queueLabel = "todoServiceQueue"
        static let maxDelay: Double = 120000
        static let minDelay: Double = 2000
        static let factor = 1.5
        static let jitter = 0.05
        static let oneHundredPercent: Double = 1
    }
}
