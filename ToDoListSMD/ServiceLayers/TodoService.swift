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
    var todoItems: [TodoItem] { get }

    func add(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func update(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func delete(_ todoItemID: String, completion: @escaping (Result<(), Error>) -> ())
    func save()

    func assignDelegate(_ delegate: TodoServiceDelegate)
}

final class TodoService: TodoServiceProtocol {
    private let fileName = Constants.fileNameForWriteCache
    private let fileCacheService: FileCacheServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let todoServiceQueue = DispatchQueue(label: Constants.queueLabel, attributes: [.concurrent])
    private weak var delegate: TodoServiceDelegate?
    private(set) var todoItems: [TodoItem] = [] {
        didSet {
            delegate?.todoItemsChanged()
        }
    }

    init(_ fileCacheService: FileCacheServiceProtocol, _ networkService: NetworkServiceProtocol) {
        self.fileCacheService = fileCacheService
        self.networkService = networkService
        loadData()
    }

    func assignDelegate(_ delegate: TodoServiceDelegate) {
        self.delegate = delegate
    }
}

// MARK: Main actions
extension TodoService {
    func add(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        addToCache(todoItem) { [weak self] result in
            DispatchQueue.main.async {
                self?.add(todoItem)
                completion(result)
            }
        }
    }

    func update(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        updateInCache(todoItem) { [weak self] result in
            DispatchQueue.main.async {
                self?.update(todoItem)
                completion(result)
            }
        }
    }

    func delete(_ todoItemID: String, completion: @escaping (Result<(), Error>) -> ()) {
        deleteFromCache(todoItemID: todoItemID) { [weak self] result in
            DispatchQueue.main.async {
                self?.delete(todoItemID)
                completion(result)
            }
        }
    }

    func save() {
        saveToCache { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                DDLogInfo(error)
                // NB: обработать
            }
        }
    }

    private func loadData() {
        loadDataFromNetwork { result in
            switch result {
            case .success(let networkItems):
                // NB: проверить синхронизацию
                self.setTodoItems(networkItems)
            case .failure:
                self.loadFromCache { result in
                    switch result {
                    case .success(let cacheItems):
                        self.setTodoItems(cacheItems)
                    case .failure(let error):
                        DDLogInfo(error)
                        // NB: обработать
                    }
                }
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

    private func setTodoItems(_ todoItems: [TodoItem]) {
        self.todoServiceQueue.async(flags: .barrier) { [weak self] in
            self?.todoItems = todoItems
        }
    }
}

// MARK: TodoItems model methods
extension TodoService {
    private func add(_ todoItem: TodoItem) {
        todoServiceQueue.async { [weak self] in
            guard !(self?.todoItems.contains(where: { $0.id == todoItem.id}) ?? true) else { return }
            self?.todoItems.append(todoItem)
        }
    }

    private func update(_ todoItem: TodoItem) {
        todoServiceQueue.async { [weak self] in
            guard let index = self?.todoItems.firstIndex(where: { $0.id == todoItem.id }) else { return }
            self?.todoItems[index] = todoItem
        }
    }

    private func delete(_ todoItemID: String) {
        todoServiceQueue.async { [weak self] in
            guard let index = self?.todoItems.firstIndex(where: { $0.id == todoItemID }) else { return }
            self?.todoItems.remove(at: index)
        }
    }
}

// MARK: Network actions
extension TodoService {
    private func loadDataFromNetwork(completion: @escaping (Result<([TodoItem]), Error>) -> ()) {

    }
}

// MARK: Cache actions
extension TodoService {
    private func addToCache(_ newTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        fileCacheService.add(newTodoItem) { result in
            completion(result)
        }
    }

    private func updateInCache(_ updatingTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        fileCacheService.update(updatingTodoItem) { result in
            completion(result)
        }
    }

    private func deleteFromCache(todoItemID: String, completion: @escaping (Result<(), Error>) -> ()) {
        fileCacheService.delete(todoItemID: todoItemID) { result in
            completion(result)
        }
    }

    private func saveToCache(completion: @escaping (Result<(), Error>) -> ()) {
        fileCacheService.save(to: fileName) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    private func loadFromCache(completion: @escaping (Result<([TodoItem]), Error>) -> ()) {
        fileCacheService.load(from: fileName) { result in
            completion(result)
        }
    }
}

extension TodoService {
    private enum Constants {
        static let queueLabel = "todoServiceQueue"
        static let fileNameForWriteCache = "TaskList.txt"
    }
}
