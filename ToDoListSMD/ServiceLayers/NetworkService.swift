//
//  NetworkService.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 14.08.2022.
//

import Foundation

protocol NetworkServiceProtocol {
    func add(_ newTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func update(_ updatingTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func delete(todoItemID: String)
    func save(completion: @escaping (Result<(), Error>) -> ())
    func load(completion: @escaping (Result<([TodoItem]), Error>) -> ())
}

final class NetworkService: NetworkServiceProtocol {
    private let networkServiceQueue = DispatchQueue(label: "networkServiceQueue")

    func add(_ newTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {
        let timeout = TimeInterval.random(in: 1..<3)
        networkServiceQueue.asyncAfter(deadline: .now() + timeout) {
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
    }

    func update(_ updatingTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {

    }

    func delete(todoItemID: String) {

    }

    func save(completion: @escaping (Result<(), Error>) -> ()) {

    }

    func load(completion: @escaping (Result<([TodoItem]), Error>) -> ()) {
        let timeout = TimeInterval.random(in: 1..<3)
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            completion(.success(([TodoItem(text: "МОК из сети")])))
        }
    }
}
