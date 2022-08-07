//
//  ListViewModel.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 07.08.2022.
//

import Foundation

protocol ListViewModelProtocol {
    func getNumberOfRows() -> Int
    func getTodoItem(for indexPath: IndexPath) -> TodoItem
}

final class ListViewModel: ListViewModelProtocol {
    private var todoItems: [TodoItem]
    private var fileCache: FileCache

    init() {
        fileCache = FileCache()
        todoItems = fileCache.todoItems
        createMopTasks()
    }

    func getTodoItem(for indexPath: IndexPath) -> TodoItem {
        todoItems[indexPath.row]
    }

    func getNumberOfRows() -> Int {
        todoItems.count
    }
}
































// MARK: Test data
extension ListViewModel {
    func createMopTasks() {
        let t1 = TodoItem(id: "11", text: "умная мысль", importance: .ordinary, isDone: false, creationDate: Date(), changeDate: nil, deadLine: Date(timeIntervalSince1970: 1231314152999))

        let t2 = TodoItem(id: "22", text: "свежая мысль", importance: .important, isDone: false, creationDate: Date(), changeDate: nil, deadLine: nil)

        let t3 = TodoItem(id: "33", text: "здесь без умной мысли", importance: .unimportant, isDone: true, creationDate: Date(), changeDate: nil, deadLine: Date())

        let t4 = TodoItem(id: "44", text: "просрочка", importance: .important, isDone: false, creationDate: Date(), changeDate: nil, deadLine: Date(timeIntervalSince1970: 124521))

        let t5 = TodoItem(id: "55", text: "сделать что-то", importance: .unimportant, isDone: true, creationDate: Date(), changeDate: nil, deadLine: nil)

        let t6 = TodoItem(id: "66", text: "разобраться со старнным прыжком клавы в textView, когда в заметке много текста", importance: .important, isDone: false, creationDate: Date(), changeDate: nil, deadLine: Date(timeIntervalSince1970: 18151))

        let t7 = TodoItem(id: "77", text: "проработать скрытие клавы", importance: .important, isDone: false, creationDate: Date(), changeDate: nil, deadLine: Date(timeIntervalSince1970: 124151))

        let t8 = TodoItem(id: "88", text: "выдавать алерты при ошибках", importance: .important, isDone: false, creationDate: Date(), changeDate: nil, deadLine: Date(timeIntervalSince1970: 12261814151))

        try? fileCache.add(t1)
        try? fileCache.add(t2)
        try? fileCache.add(t3)
        try? fileCache.add(t4)
        try? fileCache.add(t5)
        try? fileCache.add(t6)
        try? fileCache.add(t7)
        try? fileCache.add(t8)
        try? fileCache.save()
    }
}

