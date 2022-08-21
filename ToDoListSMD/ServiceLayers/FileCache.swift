//
//  FileCache.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 27.07.2022.
//

import Foundation
import CocoaLumberjack
import Helpers

final class FileCache {
    private(set) var todoItems: [TodoItem] = []

    func add(_ todoItem: TodoItem) throws {
        guard !todoItems.contains(where: { $0.id == todoItem.id }) else { throw CacheError.existingID }
        todoItems.append(todoItem)
    }

    func update(_ todoItem: TodoItem) throws {
        guard let index = todoItems.firstIndex(where: { $0.id == todoItem.id }) else { throw CacheError.nonexistentID }
        todoItems[index] = todoItem
    }

    func delete(_ todoItemID: String) throws {
        guard let index = todoItems.firstIndex(where: { $0.id == todoItemID }) else { throw CacheError.nonexistentID }
        todoItems.remove(at: index)
    }

    func save(_ file: String) throws {
        let jsonDict = todoItems.map { $0.json }
        guard JSONSerialization.isValidJSONObject(jsonDict),
              let path = getPath(to: file),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict) else {
            throw JSONError.serializationError
        }

        do {
            try jsonData.write(to: path)
        } catch {
            throw CacheError.savingError
        }
    }

    func load(_ file: String) throws {
        guard let path = getPath(to: file) else { throw CacheError.invalidPath }
        guard let jsonData = try? Data(contentsOf: path) else { throw JSONError.deserializationError }
        guard let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [Any] else { throw CacheError.loadingError }
        todoItems = jsonDict.compactMap { TodoItem.parse(json: $0) }
    }

    func reloadCache(with todoItems: [TodoItem]) {
        self.todoItems = todoItems
    }

    private func getPath(to file: String) -> URL? {
        guard var path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }

        path.appendPathComponent(file)
        return path
    }
}
