//
//  FileCacheService.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 14.08.2022.
//

import Foundation
import Helpers

protocol FileCacheServiceProtocol {
    func add(_ newTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func update(_ updatingTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func delete(todoItemID: String)
    func save(to file: String, completion: @escaping (Result<(), Error>) -> ())
    func load(from file: String, completion: @escaping (Result<([TodoItem]), Error>) -> ())
}

final class FileCacheService: FileCacheServiceProtocol {
    private let fileCache: FileCache = FileCache()
    private let fileCacheQueue = DispatchQueue(label: "fileCacheQueue")

    func add(_ newTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        fileCacheQueue.async { [weak self] in
            do {
                try self?.fileCache.add(newTodoItem)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func update(_ updatingTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        fileCacheQueue.async { [weak self] in
            do {
                try self?.fileCache.update(updatingTodoItem)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func delete(todoItemID: String) {
        fileCacheQueue.async { [weak self] in
            self?.fileCache.delete(todoItemID)
        }
    }

    func save(to file: String, completion: @escaping (Result<(), Error>) -> ()) {
        fileCacheQueue.async { [weak self] in
            do {
                try self?.fileCache.save(file)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func load(from file: String, completion: @escaping (Result<([TodoItem]), Error>) -> ()) {
        fileCacheQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                try self.fileCache.load(file)
                completion(.success(self.fileCache.todoItems.value))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
