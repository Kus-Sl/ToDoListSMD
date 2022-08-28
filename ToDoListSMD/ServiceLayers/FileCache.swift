//
//  FileCache.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 27.07.2022.
//

import Foundation
import CoreData
import CocoaLumberjack
import Helpers

// Working with Core Data
final class FileCache {
    var todoItems: [TodoItem] {
        todoItemsCD.map { TodoItem($0) }
    }

    private(set) var todoItemsCD: [TodoItemCD] = []
    private let context: NSManagedObjectContext

    private let fileName = Constants.fileNameForWriteCache

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.persistentContainerName)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("\(error) | \(error.userInfo)")
            }
        })
        return container
    }()

    init() {
        context = persistentContainer.viewContext
    }

    func add(_ todoItem: TodoItem) throws {
        guard !todoItemsCD.contains(where: { $0.id == todoItem.id }) else { throw CacheErrors.existingID }
        let newTodoItemCD = TodoItemCD(context: context)
        convert(todoItem, to: newTodoItemCD)
        todoItemsCD.append(newTodoItemCD)
        try save()
    }

    func update(_ todoItem: TodoItem) throws {
        guard let index = todoItemsCD.firstIndex(where: { $0.id == todoItem.id }) else { throw CacheErrors.nonexistentID }
        let updatingTodoItemCD = todoItemsCD[index]
        convert(todoItem, to: updatingTodoItemCD)
        try save()
    }

    func delete(_ todoItemID: String) throws {
        guard let index = todoItemsCD.firstIndex(where: { $0.id == todoItemID }) else { throw CacheErrors.nonexistentID }
        context.delete(todoItemsCD[index])
        try save()
    }

    func load() throws {
        let fetchRequest = TodoItemCD.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: Constants.sortKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        guard let todoItemsCD = try? context.fetch(fetchRequest) else { throw CacheErrors.loadingError }
        self.todoItemsCD = todoItemsCD
        guard !todoItemsCD.isEmpty else { throw CacheErrors.emptyCache }
//        todoItemsCD.forEach { print($0) }
    }

    func reloadCache(with todoItems: [TodoItem]) {
        todoItemsCD.forEach { context.delete($0) }
        for todoItem in todoItems {
            let todoItemCD = TodoItemCD(context: context)
            convert(todoItem, to: todoItemCD)
        }

        try? save()
    }

    private func save() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            throw CacheErrors.savingError
        }
    }
}

// MARK: Support methods
extension FileCache {
    private func convert(_ todoItem: TodoItem, to todoItemCD: TodoItemCD) {
        todoItemCD.id = todoItem.id
        todoItemCD.text = todoItem.text
        todoItemCD.importance = todoItem.importance
        todoItemCD.isDone = todoItem.isDone
        todoItemCD.creationDate = Int64(todoItem.creationDate)
        todoItemCD.changeDate = Int64(todoItem.changeDate ?? Constants.optionalDefaultValue)
        todoItemCD.deadLine = Int64(todoItem.deadline ?? Constants.optionalDefaultValue)
        todoItemCD.isDirty = todoItem.isDirty
    }

    // не забыл удалить, а оставил для себя на будущее))
    private func resetCoreData() {
        let persistentCoordinator = persistentContainer.persistentStoreCoordinator
        guard let persistentStore = persistentCoordinator.persistentStores.first else { return }
        guard let persistentStoreURL = persistentStore.url else { return }

        try? persistentCoordinator.destroyPersistentStore(
            at: persistentStoreURL,
            ofType: persistentStore.type,
            options: nil
        )
    }

    // не забыл удалить, а оставил для себя на будущее))
    private func fetchTodoItemCD(with todoItemID: String) throws -> TodoItemCD? {
        let fetchRequest = TodoItemCD.fetchRequest()
        let predicate =  NSPredicate(format: Constants.formatForPredicate, todoItemID)
        fetchRequest.predicate = predicate
        guard let todoItemCD = try? context.fetch(fetchRequest) else { throw CacheErrors.loadingError }
        return todoItemCD.first
    }
}

// MARK: Constants
extension FileCache {
    private enum Constants {
        static let fileNameForWriteCache = "TaskList.txt"
        static let persistentContainerName = "ToDoListSMD"
        static let formatForPredicate = "id == %@"
        static let sortKey = "creationDate"
        static let optionalDefaultValue = 0
    }
}

// MARK: Working with file
/*
final class FileCache {
    private let fileName = Constants.fileNameForWriteCache
    private(set) var todoItems: [TodoItem] = []

    func add(_ todoItem: TodoItem) throws {
        guard !todoItems.contains(where: { $0.id == todoItem.id }) else { throw CacheErrors.existingID }
        todoItems.append(todoItem)
    }

    func update(_ todoItem: TodoItem) throws {
        guard let index = todoItems.firstIndex(where: { $0.id == todoItem.id }) else { throw CacheErrors.nonexistentID }
        todoItems[index] = todoItem
    }

    func delete(_ todoItemID: String) throws {
        guard let index = todoItems.firstIndex(where: { $0.id == todoItemID }) else { throw CacheErrors.nonexistentID }
        todoItems.remove(at: index)
    }

    func save() throws {
        let jsonDict = todoItems.map { $0.json }
        guard JSONSerialization.isValidJSONObject(jsonDict),
              let path = getPath(to: fileName),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict) else {
            throw JSONErrors.serializationError
        }

        do {
            try jsonData.write(to: path)
        } catch {
            throw CacheErrors.savingError
        }
    }

    func load() throws {
        guard let path = getPath(to: fileName) else { throw CacheErrors.invalidPath }
        guard let jsonData = try? Data(contentsOf: path) else { throw JSONErrors.deserializationError }
        guard let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [Any] else { throw CacheErrors.loadingError }
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
*/
