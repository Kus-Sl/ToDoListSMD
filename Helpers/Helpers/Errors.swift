//
//  Errors.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 06.08.2022.
//

import Foundation

public enum CacheErrors: Error {
    case invalidPath
    case existingID
    case nonexistentID
    case loadingError
    case savingError
    case emptyCache
}

public enum JSONErrors: Error {
    case serializationError
    case deserializationError
}

public enum NetworkErrors: Int, Error {
    case incorrectRequest = 400
    case incorrectToken = 401
    case notFound = 404
    case serverError = 500
    case incorrectUrl
    case noConnection
    case unownedError
    case noResponseData
}
