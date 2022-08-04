//
//  FileCache.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 27.07.2022.
//

import Foundation

class FileCache {
    private(set) var todoItems: [TodoItem] = []

    func add(_ todoItem: TodoItem) throws {
        if !todoItems.contains(where: { $0.id == todoItem.id }) {
            todoItems.append(todoItem)
        } else {
            throw CacheError.existingID
        }
    }

    func delete(_ todoItemID: String) {
        guard let index = todoItems.firstIndex(where: { $0.id == todoItemID }) else { return }
        todoItems.remove(at: index)
    }

    func load(_ file: String = "TaskList.txt") {
        guard let path = getPath(to: file),
              let jsonData = try? Data(contentsOf: path),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData) as? [Any] else {
            return
        }

        todoItems = jsonDict.compactMap { TodoItem.parse(json: $0) }
    }

    func save(_ file: String = "TaskList.txt") {
        let jsonDict = todoItems.map { $0.json }

        guard JSONSerialization.isValidJSONObject(jsonDict),
              let path = getPath(to: file),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict) else {
            return
        }

        try? jsonData.write(to: path)
    }

    private func getPath(to file: String) -> URL? {
        guard var path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }

        path.appendPathComponent(file)
        return path
    }
}

enum CacheError: Error {
    case existingID
}















