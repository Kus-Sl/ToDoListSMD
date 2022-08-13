//
//  FileCache.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 27.07.2022.
//

import Foundation
import CocoaLumberjack

class FileCache {
    static private let fileName = "TaskList.txt"
    private(set) var todoItems: Box<[TodoItem]> = Box(value: [])

    init() {
        try? load()
    }

    func add(_ todoItem: TodoItem) throws {
        guard !todoItems.value.contains(where: { $0.id == todoItem.id }) else { throw CacheError.existingID }
        todoItems.value.append(todoItem)
    }

    func update( _ todoItem: TodoItem) throws {
        guard let index = todoItems.value.firstIndex(where: { $0.id == todoItem.id }) else { throw CacheError.nonexistentID }
        todoItems.value[index] = todoItem
    }

    func delete(_ todoItemID: String) {
        guard let index = todoItems.value.firstIndex(where: { $0.id == todoItemID }) else { return }
        todoItems.value.remove(at: index)
    }

    func load(_ file: String = fileName) throws {
        guard let path = getPath(to: file) else { throw CacheError.invalidPath }
        guard let jsonData = try? Data(contentsOf: path) else { throw JSONError.deserializationError }
        guard let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [Any] else { throw CacheError.loadingError }
        todoItems.value = jsonDict.compactMap { TodoItem.parse(json: $0) }
    }

    func save(_ file: String = fileName) throws {
        let jsonDict = todoItems.value.map { $0.json }

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

    private func getPath(to file: String) -> URL? {
        guard var path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }

        path.appendPathComponent(file)
        return path
    }
}
