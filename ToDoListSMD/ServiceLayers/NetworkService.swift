//
//  NetworkService.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 14.08.2022.
//

import Foundation
import Helpers

protocol NetworkServiceProtocol {
    func add(_ newTodoItem: TodoItem, completion: @escaping (Result<(TodoItem), Error>) -> ())
    func update(_ updatingTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ())
    func delete(todoItemID: String)
    func sync(_ todoItems: [TodoItem], completion: @escaping (Result<([TodoItem]), Error>) -> ())
    func fetchAllTodoItems(completion: @escaping (Result<([TodoItem]), Error>) -> ())
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://beta.mrdekk.ru/todobackend/list"
    private let networkServiceQueue = DispatchQueue(label: "networkServiceQueue", attributes: [.concurrent])
    private let customSession: URLSession = {
        let session = URLSession.init(configuration: .default)
        session.configuration.timeoutIntervalForRequest = 15.0
        return session
    }()

    func add(_ newTodoItem: TodoItem, completion: @escaping (Result<(TodoItem), Error>) -> ()) {
        let todoItemNetwork = TodoItemNetwork(newTodoItem)
        guard let url = createURL(baseURL) else {
            completion(.failure(NetworkErrors.incorrectUrl))
            return
        }

        guard let body = try? JSONEncoder().encode(Response(element: todoItemNetwork, list: nil, revision: nil)) else {
            completion(.failure(JSONError.serializationError))
            return
        }

        guard let request = createRequest(with: url, httpMethod: .post, httpBody: body, revisionNumber: 0) else {
            completion(.failure(NetworkErrors.incorrectRequest))
            return
        }

        let task = createTask(with: request, completion: completion)
        networkServiceQueue.async {
            task.resume()
        }
    }

    func update(_ updatingTodoItem: TodoItem, completion: @escaping (Result<(), Error>) -> ()) {

    }

    func delete(todoItemID: String) {

    }

    func sync(_ todoItems: [TodoItem], completion: @escaping (Result<([TodoItem]), Error>) -> ()) {

    }

    func fetchAllTodoItems(completion: @escaping (Result<([TodoItem]), Error>) -> ()) {

    }
}

// MARK: Support methods
extension NetworkService {
    private func createURL(_ baseURL: String, todoItemID: String? = nil) -> URL? {
        var url = baseURL

        if let todoItemID = todoItemID {
            url.append(contentsOf: "/")
            url.append(contentsOf: todoItemID)
        }

        guard let url = URL(string: url) else { return nil }
        return url
    }

    private func createRequest(with url: URL, httpMethod: HTTPMethods, httpBody: Data? = nil, revisionNumber: Int? = nil) -> URLRequest? {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.setValue("Bearer AbnormalBloodMagic", forHTTPHeaderField: "Authorization")

        guard let httpBody = httpBody, let revisionNumber = revisionNumber else {
            return urlRequest
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(revisionNumber)", forHTTPHeaderField: "X-Last-Known-Revision")
        urlRequest.httpBody = httpBody
        return urlRequest
    }

    private func createTask(with urlRequest: URLRequest, completion: @escaping (Result<[TodoItem], Error>) -> ()) -> URLSessionDataTask {
        let task = customSession.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                completion(.failure(NetworkErrors.noConnection))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkErrors.unownedError))
                return
            }

            guard self.isSuccessResponse(response.statusCode) else {
                let error = NetworkErrors(rawValue: response.statusCode)
                completion(.failure(error ?? .notFound))
                return
            }

            guard let networkResponse = try? JSONDecoder().decode(Response.self, from: data) else {
                completion(.failure(JSONError.deserializationError))
                return
            }

            guard let todoItemsNetwork = networkResponse.list else {
                completion(.failure(JSONError.deserializationError))
                return
            }

            let todoItems = todoItemsNetwork.map { TodoItem($0) }
            completion(.success(todoItems))
        }

        return task
    }

    private func createTask(with urlRequest: URLRequest, completion: @escaping (Result<TodoItem, Error>) -> ()) -> URLSessionDataTask {
        let task = customSession.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                completion(.failure(NetworkErrors.noConnection))
                return
            }

            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkErrors.unownedError))
                return
            }

            guard self.isSuccessResponse(response.statusCode) else {
                let error = NetworkErrors(rawValue: response.statusCode)
                completion(.failure(error ?? .notFound))
                return
            }

            guard let networkResponse = try? JSONDecoder().decode(Response.self, from: data) else {
                completion(.failure(JSONError.deserializationError))
                return
            }

            guard let todoItemNetwork = networkResponse.element else {
                completion(.failure(JSONError.deserializationError))
                return
            }

            let todoItem = TodoItem(todoItemNetwork)
            completion(.success(todoItem))
        }

        return task
    }

    private func isSuccessResponse(_ statusCode: Int) -> Bool {
        guard NetworkErrors.init(rawValue: statusCode) != nil else { return true }
        return false
    }
}

extension NetworkService {
    private enum HTTPMethods: String {
        case get = "GET"
        case patch = "PATCH"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
}
