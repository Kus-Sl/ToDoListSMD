//
//  Errors.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 06.08.2022.
//

import Foundation

public enum CacheError: Error {
    case invalidPath
    case existingID
    case nonexistentID
    case loadingError
    case savingError
}

public enum JSONError: Error {
    case serializationError
    case deserializationError
}
