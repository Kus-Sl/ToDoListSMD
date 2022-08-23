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
    func save()
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
    private let fileName = Constants.fileNameForWriteCache
    private let networkService: NetworkServiceProtocol
    private var fileCacheService: FileCacheServiceProtocol

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
        delegate?.requestStarted()
        networkService.add(todoItem, lastKnownRevision: fileCacheService.lastKnownRevision) { [weak self] result in
            switch result {
            case .success(let revision):
                self?.delegate?.requestEnded()
                self?.fileCacheService.lastKnownRevision = revision
                self?.fileCacheService.add(todoItem) { cacheResult in

                }
            case .failure(let error):
                self?.fileCacheService.add(todoItem.asDirty) { cacheResult in

                }
                DDLogInfo(error)
                // Помечаю как NeedsSync и пытаюсь повторить, вызывая retry
            }
        }
    }

    func update(_ todoItem: TodoItem) {
        updateIntoCurrentList(todoItem)
        delegate?.requestStarted()
        networkService.update(todoItem, lastKnownRevision: fileCacheService.lastKnownRevision) { [weak self] result in
            switch result {
            case .success(let revision):
                self?.delegate?.requestEnded()
                self?.fileCacheService.lastKnownRevision = revision
                self?.fileCacheService.update(todoItem) { cacheResult in
                }
            case .failure(let error):
                self?.fileCacheService.update(todoItem.asDirty) { cacheResult in
                    switch cacheResult {
                    case .success:
                        break
                    case .failure(let error):
                        DDLogInfo(error)
                    }
                }
                DDLogInfo(error)
                // Помечаю как NeedsSync и пытаюсь повторить, вызывая retry
            }
        }
    }

    func delete(_ todoItemID: String) {
        deleteFromCurrentList(todoItemID)
        delegate?.requestStarted()
        networkService.delete(todoItemID: todoItemID, lastKnownRevision: fileCacheService.lastKnownRevision) { [weak self] result in
            self?.delegate?.requestEnded()
            self?.fileCacheService.delete(todoItemID: todoItemID) { cacheResult in
            }
            switch result {
            case .success(let revision):
                self?.fileCacheService.lastKnownRevision = revision
            case .failure(let error):
                self?.fileCacheService.isTombstonesExist = true
                DDLogInfo(error)
                // Помечаю как NeedsSync и пытаюсь повторить, вызывая retry
            }
        }
    }

    func save() {
        fileCacheService.save(to: fileName) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                DDLogInfo(error)
            }
        }
    }

    func load() {
        delegate?.requestStarted()
        fileCacheService.load(from: fileName) { [weak self] result in
            switch result {
            case .success(let cacheItems):
                self?.loadToCurrentList(cacheItems)
                self?.networkService.fetchTodoItems { result in
                    switch result {
                    case .success((_, let revision)):
                        self?.syncIfNeeded(revision)
                    case .failure(let error):
                        DDLogInfo(error)
                        // Помечаю как NeedsSync и пытаюсь повторить, вызывая retry
                    }
                }
            case .failure(let error):
                DDLogInfo(error)
                // NB: обработать
                self?.networkService.fetchTodoItems { result in
                    switch result {
                    case .success((let todoItems, let revision)):
                        self?.loadToCurrentList(todoItems)
                        self?.fileCacheService.lastKnownRevision = revision
                        self?.fileCacheService.reloadCache(with: todoItems)
                        self?.delegate?.requestEnded()
                    case .failure(let error):
                        DDLogInfo(error)
                        // Помечаю как NeedsSync и пытаюсь повторить, вызывая retry
                    }
                }
            }
        }
    }
}

// MARK: Sync methods
extension TodoService {
    private func syncIfNeeded(_ revision: Int) {
        guard fileCacheService.isDirtiesExist
                || fileCacheService.isTombstonesExist
                || revision != fileCacheService.lastKnownRevision else {
            delegate?.requestEnded()
            return
        }

        sync()
    }

    private func sync() {
        self.networkService.sync(threadSafeTodoItems) { [weak self] result in
            switch result {
            case .success((let todoItems, let revision)):
                self?.delegate?.requestEnded()
                self?.loadToCurrentList(todoItems)
                self?.fileCacheService.lastKnownRevision = revision
                self?.fileCacheService.isTombstonesExist = false
                self?.fileCacheService.reloadCache(with: todoItems)
            case .failure(let error):
                DDLogInfo(error)
                // Помечаю как NeedsSync и пытаюсь повторить, вызывая retry
            }
        }
    }
}

// MARK: TodoItems model methods
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

// MARK: Support methods
extension TodoService {
    func callDelegate() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.todoItemsChanged()
        }
    }
}

// MARK: Constants
extension TodoService {
    private enum Constants {
        static let queueLabel = "todoServiceQueue"
        static let fileNameForWriteCache = "TaskList.txt"
    }
}
