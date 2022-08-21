//
//  TodoService.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 14.08.2022.
//

import Foundation
import CocoaLumberjack
import Helpers

protocol TodoServiceDelegate: AnyObject {
    func todoItemsChanged()
}

protocol TodoServiceProtocol {
    var threadSafeTodoItems: [TodoItem] { get }

    func add(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func update(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func delete(_ todoItemID: String, completion: @escaping (Result<(), Error>) -> ())
    func save()

    func assignDelegate(_ delegate: TodoServiceDelegate)
}

final class TodoService: TodoServiceProtocol {
    var threadSafeTodoItems: [TodoItem] {
        todoServiceQueue.sync {
            return todoItems
        }
    }

    private let fileName = Constants.fileNameForWriteCache
    private let fileCacheService: FileCacheServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let todoServiceQueue = DispatchQueue(label: Constants.queueLabel, attributes: [.concurrent])
    private weak var delegate: TodoServiceDelegate?

    private var todoItems: [TodoItem] = [] {
        didSet { callDelegate() }
    }

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
    func add(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        add(todoItem)
        fileCacheService.add(todoItem) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func update(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        update(todoItem)
        fileCacheService.update(todoItem) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func delete(_ todoItemID: String, completion: @escaping (Result<(), Error>) -> ()) {
        delete(todoItemID)
        fileCacheService.delete(todoItemID: todoItemID) { result in
            DispatchQueue.main.async {
                completion(result)
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
                // NB: обработать
            }
        }
    }

    private func load() {
        fileCacheService.load(from: fileName) { result in
            switch result {
            case .success(let cacheItems):
                self.load(cacheItems)
            case .failure(let error):
                DDLogInfo(error)
                // NB: обработать
            }
        }
    }
}

// MARK: Sync methods
extension TodoService {
    private func isSynchronized() {

    }

    private func synchronizeData() {

    }
}

// MARK: TodoItems model methods
extension TodoService {
    private func add(_ todoItem: TodoItem) {
        todoServiceQueue.async(flags: .barrier) { [weak self] in
            guard !(self?.todoItems.contains(where: { $0.id == todoItem.id}) ?? true) else { return }
            self?.todoItems.append(todoItem)
        }
    }

    private func update(_ todoItem: TodoItem) {
        todoServiceQueue.async(flags: .barrier) { [weak self] in
            guard let index = self?.todoItems.firstIndex(where: { $0.id == todoItem.id }) else { return }
            self?.todoItems[index] = todoItem
        }
    }

    private func delete(_ todoItemID: String) {
        todoServiceQueue.async(flags: .barrier) { [weak self] in
            guard let index = self?.todoItems.firstIndex(where: { $0.id == todoItemID }) else { return }
            self?.todoItems.remove(at: index)
        }
    }

    private func load(_ todoItems: [TodoItem]) {
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
