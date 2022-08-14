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

final class NetworkService {
    
}
