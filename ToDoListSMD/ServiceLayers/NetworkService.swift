//
//  NetworkService.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 14.08.2022.
//

import Foundation
import Helpers
import CocoaLumberjack

protocol NetworkServiceProtocol {
    func add(_ newTodoItem: TodoItem, lastKnownRevision: Int, completion: @escaping (Result<Int, Error>) -> ())
    func update(_ updatingTodoItem: TodoItem, lastKnownRevision: Int, completion: @escaping (Result<Int, Error>) -> ())
    func delete(todoItemID: String, lastKnownRevision: Int, completion: @escaping (Result<Int, Error>) -> ())
    func sync(_ todoItems: [TodoItem], completion: @escaping (Result<([TodoItem], Int), Error>) -> ())
    func fetchTodoItems(completion: @escaping (Result<([TodoItem], Int), Error>) -> ())
}

final class NetworkService: NetworkServiceProtocol {
    private static let baseURL = Constants.baseURL
    private let networkServiceQueue = DispatchQueue(label: Constants.queueLabel, attributes: [.concurrent])
    private let customSession: URLSession = {
        let session = URLSession.init(configuration: .default)
        session.configuration.timeoutIntervalForRequest = Constants.timeoutInterval
        return session
    }()

    func add(_ newTodoItem: TodoItem, lastKnownRevision: Int, completion: @escaping (Result<Int, Error>) -> ()) {
        let todoItemNetwork = TodoItemNetwork(newTodoItem)
        guard let url = createURL(NetworkService.baseURL) else {
            completion(.failure(NetworkErrors.incorrectUrl))
            return
        }

        guard let body = try? JSONEncoder().encode(Response(element: todoItemNetwork, list: nil, revision: nil)) else {
            completion(.failure(JSONError.serializationError))
            return
        }

        guard let request = createRequest(with: url, httpMethod: .post, httpBody: body, revision: lastKnownRevision) else {
            completion(.failure(NetworkErrors.incorrectRequest))
            return
        }

        let task = createTask(with: request) { [weak self] result in
            self?.handleElementResult(result: result, completion: completion)
        }

        networkServiceQueue.async {
            task.resume()
        }
    }

    func update(_ updatingTodoItem: TodoItem, lastKnownRevision: Int, completion: @escaping (Result<Int, Error>) -> ()) {
        let todoItemNetwork = TodoItemNetwork(updatingTodoItem)
        guard let url = createURL(NetworkService.baseURL, todoItemID: todoItemNetwork.id) else {
            completion(.failure(NetworkErrors.incorrectUrl))
            return
        }

        guard let body = try? JSONEncoder().encode(Response(element: todoItemNetwork, list: nil, revision: nil)) else {
            completion(.failure(JSONError.serializationError))
            return
        }

        guard let request = createRequest(with: url, httpMethod: .put, httpBody: body, revision: lastKnownRevision) else {
            completion(.failure(NetworkErrors.incorrectRequest))
            return
        }

        let task = createTask(with: request) { [weak self] result in
            self?.handleElementResult(result: result, completion: completion)
        }

        networkServiceQueue.async {
            task.resume()
        }
    }

    func delete(todoItemID: String, lastKnownRevision: Int, completion: @escaping (Result<Int, Error>) -> ()) {
        guard let url = createURL(NetworkService.baseURL, todoItemID: todoItemID) else {
            completion(.failure(NetworkErrors.incorrectUrl))
            return
        }

        guard let request = createRequest(with: url, httpMethod: .delete, revision: lastKnownRevision) else {
            completion(.failure(NetworkErrors.incorrectRequest))
            return
        }

        let task = createTask(with: request) { [weak self] result in
            self?.handleElementResult(result: result, completion: completion)
        }

        networkServiceQueue.async {
            task.resume()
        }
    }

    func sync(_ todoItems: [TodoItem], completion: @escaping (Result<([TodoItem], Int), Error>) -> ()) {
        let todoItemsNetwork = todoItems.map { TodoItemNetwork($0) }
        guard let url = createURL(NetworkService.baseURL) else {
            completion(.failure(NetworkErrors.incorrectUrl))
            return
        }

        guard let body = try? JSONEncoder().encode(Response(element: nil, list: todoItemsNetwork, revision: nil)) else {
            completion(.failure(JSONError.serializationError))
            return
        }

        guard let request = createRequest(with: url, httpMethod: .patch, httpBody: body, revision: 0) else {
            completion(.failure(NetworkErrors.incorrectRequest))
            return
        }

        let task = createTask(with: request) { [weak self] result in
            self?.handleListResult(result: result, completion: completion)
        }

        networkServiceQueue.async {
            task.resume()
        }
    }

    func fetchTodoItems(completion: @escaping (Result<([TodoItem], Int), Error>) -> ()) {
        guard let url = createURL(NetworkService.baseURL) else {
            completion(.failure(NetworkErrors.incorrectUrl))
            return
        }

        guard let request = createRequest(with: url, httpMethod: .get) else {
            completion(.failure(NetworkErrors.incorrectRequest))
            return
        }

        let task = createTask(with: request) { [weak self] result in
            self?.handleListResult(result: result, completion: completion)
        }

        networkServiceQueue.async {
            task.resume()
        }
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

    private func createRequest(with url: URL, httpMethod: HTTPMethods, httpBody: Data? = nil, revision: Int? = nil) -> URLRequest? {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.setValue(Constants.headerBearerTokenValue, forHTTPHeaderField: Constants.headerBearerTokenField)

        if let httpBody = httpBody {
            urlRequest.setValue(Constants.headerContentTypeValue, forHTTPHeaderField: Constants.headerContentTypeField)
            urlRequest.httpBody = httpBody
        }

        if let revision = revision {
            urlRequest.setValue("\(revision)", forHTTPHeaderField: Constants.headerRevisionField)
        }

        return urlRequest
    }

    private func createTask(with urlRequest: URLRequest, completion: @escaping (Result<Response, Error>) -> ()) -> URLSessionDataTask {
        let task = customSession.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
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

            completion(.success(networkResponse))
        }

        return task
    }

    private func isSuccessResponse(_ statusCode: Int) -> Bool {
        guard NetworkErrors.init(rawValue: statusCode) != nil else { return true }
        return false
    }

    private func handleElementResult(result: Result<Response, Error>, completion: @escaping (Result<Int, Error>) -> ()) {
        switch result {
        case .success(let response):
            guard let revision = response.revision else {
                completion(.failure(NetworkErrors.noResponseData))
                return
            }

            DispatchQueue.main.async {
                completion(.success(revision))
            }

        case .failure(let error):
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

    private func handleListResult(result: Result<Response, Error>, completion: @escaping (Result<([TodoItem], Int), Error>) -> ()) {
        switch result {
        case .success(let response):
            guard let revision = response.revision, let todoItemsNetwork = response.list else {
                completion(.failure(NetworkErrors.noResponseData))
                return
            }

            let todoItems = todoItemsNetwork.map { TodoItem($0) }
            let responceData = (actualList: todoItems, actualRevision: revision)
            DispatchQueue.main.async {
                completion(.success(responceData))
            }
            
        case .failure(let error):
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}

// MARK: Constants
extension NetworkService {
    private enum HTTPMethods: String {
        case get = "GET"
        case patch = "PATCH"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }

    private enum Constants {
        static let baseURL = "https://beta.mrdekk.ru/todobackend/list"
        static let queueLabel = "networkServiceQueue"
        static let headerContentTypeField = "Content-Type"
        static let headerContentTypeValue = "application/json"
        static let headerRevisionField = "X-Last-Known-Revision"
        static let headerBearerTokenField = "Authorization"
        static let headerBearerTokenValue = "Bearer AbnormalBloodMagic"
        static let timeoutInterval: Double = 15
    }
}
