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
    func add(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func update(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func delete(_ todoItemID: String, completion: @escaping (Result<(), Error>) -> ())
    func save()
}

final class TodoService: TodoServiceProtocol {
    private let fileName = "TaskList.txt"
    private let fileCacheService: FileCacheServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let todoServiceQueue = DispatchQueue(label: "todoServiceQueue", attributes: [.concurrent])
    private var todoItems: Box<[TodoItem]> = Box(value: []) // завязать модель с этим

    init(fileCacheService: FileCacheServiceProtocol, networkService: NetworkServiceProtocol) {
        self.fileCacheService = fileCacheService
        self.networkService = networkService
        loadData()
    }
}

// MARK: Main actions
extension TodoService {
    func add(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        addToCache(todoItem) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func update(_ todoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        updateInCache(todoItem) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func delete(_ todoItemID: String, completion: @escaping (Result<(), Error>) -> ()) {
        deleteFromCache(todoItemID: todoItemID) { result in
            DispatchQueue.main.async {
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
                // NB: выдать аллерт
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
                        // NB: выдать аллерт
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
            self?.todoItems.value = todoItems
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
