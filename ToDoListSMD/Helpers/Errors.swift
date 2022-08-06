//
//  Errors.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 06.08.2022.
//

import Foundation

enum CacheError: Error {
    case invalidPath
    case existingID
    case loadingError
    case savingError
}

enum JSONError: Error {
    case serializationError
    case deserializationError
}
