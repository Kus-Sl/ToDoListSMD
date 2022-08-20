//
//  FileCacheService.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 14.08.2022.
//

import Foundation
import CocoaLumberjack
import Helpers

protocol FileCacheServiceProtocol {
    func add(_ newTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func update(_ updatingTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func delete(todoItemID: String, completion: @escaping (Result<(), Error>) -> ())
    func save(to file: String, completion: @escaping (Result<(), Error>) -> ())
    func load(from file: String, completion: @escaping (Result<([TodoItem]), Error>) -> ())
}

final class FileCacheService: FileCacheServiceProtocol {
    private let fileCache: FileCache = FileCache()
    private let fileCacheQueue = DispatchQueue(label: Constants.queueLabel, attributes: [.concurrent])

    func add(_ newTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        callAction(completion: completion) { [weak self] in
             try self?.fileCache.add(newTodoItem)
        }
    }

    func update(_ updatingTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        callAction(completion: completion) { [weak self] in
            try self?.fileCache.update(updatingTodoItem)
        }
    }

    func delete(todoItemID: String, completion: @escaping (Result<(), Error>) -> ()) {
        callAction(completion: completion) { [weak self] in
            try self?.fileCache.delete(todoItemID)
        }
    }

    func save(to file: String, completion: @escaping (Result<(), Error>) -> ()) {
        callAction(completion: completion) { [weak self] in
            try self?.fileCache.save(file)
        }
    }

    func load(from file: String, completion: @escaping (Result<([TodoItem]), Error>) -> ()) {
        fileCacheQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.fileCache.load(file)
                DispatchQueue.main.async {
                    completion(.success(self.fileCache.todoItems))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: Support methods
extension FileCacheService {
    private func callAction(completion: @escaping (Result<(), Error>) -> (), action: @escaping () throws -> ()) {
        fileCacheQueue.async(flags: .barrier) {
            do {
                try action()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: Constants
extension FileCacheService {
    private enum Constants {
        static let queueLabel = "fileCacheQueue"
    }
}
