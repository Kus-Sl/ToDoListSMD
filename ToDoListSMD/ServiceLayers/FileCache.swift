//
//  FileCache.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 27.07.2022.
//

import Foundation
class FileCache {
    static let shared = FileCache()

    private init () {}

    private(set) var todoItems: [TodoItem] = []

    func add(_ todoItem: TodoItem) {
        todoItems.append(todoItem)
    }

    func delete(_ todoItemID: String) {
        if let index = todoItems.firstIndex(where: { $0.id == todoItemID }) {
            todoItems.remove(at: index)
        }
    }

    func getItems(from file: String = "Cache.txt") {
        guard let path = getPath(to: file),
              let jsonData = try? Data(contentsOf: path),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData) as? [Any]
        else { return }

        todoItems = jsonDict.compactMap { TodoItem.parse(json: $0) }
    }

    func saveItems(to file: String = "Cache.txt") {
        let jsonDict = todoItems.map { $0.json }

        guard JSONSerialization.isValidJSONObject(jsonDict),
              let path = getPath(to: file),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict)
        else { return }

        try? jsonData.write(to: path)
    }

    private func getPath(to file: String) -> URL? {
        guard var path = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else { return nil }

        path.appendPathComponent(file)
        return path
    }
}















