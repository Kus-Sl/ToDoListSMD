//
//  ListViewModel.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 07.08.2022.
//

import Foundation
import CocoaLumberjack

protocol ListViewModelProtocol {
    var isFilteredWithoutCompletedItems: Bool { get set }

    func bindViewControllerWithModel(_ listener: @escaping ([TodoItem]) -> ())
    func createDetailViewModel(for indexPath: IndexPath?) -> DetailViewModel

    func completeTodoItem(with indexPath: IndexPath)
    func deleteTodoItem(with indexPath: IndexPath)

    func getNumberOfRows() -> Int
    func getTodoItem(for indexPath: IndexPath) -> TodoItem
    func getCompletedTodoItemsCount() -> Int
}

final class ListViewModel: ListViewModelProtocol {
    var isFilteredWithoutCompletedItems = false

    private var uncompletedTodoItems: [TodoItem] {
        fileCache.todoItems.value.filter { !$0.isDone }
    }

    private lazy var fileCache = FileCache()

    func bindViewControllerWithModel(_ listener: @escaping ([TodoItem]) -> ()) {
        fileCache.todoItems.listener = listener
    }

    func createDetailViewModel(for indexPath: IndexPath?) -> DetailViewModel {
        guard let indexPath = indexPath else {
            return DetailViewModel(todoItem: TodoItem(text: ""), fileCache: fileCache)
        }

        return DetailViewModel(todoItem: getTodoItem(for: indexPath), fileCache: fileCache)
    }
}

// MARK: Actions
extension ListViewModel {
    func completeTodoItem(with indexPath: IndexPath) {
        let completedTodoItem = fileCache.todoItems.value[indexPath.row].asCompleted
        do {
            try fileCache.update(completedTodoItem)
        } catch {
            // NB: Показать алерт
        }
    }

    func deleteTodoItem(with indexPath: IndexPath) {
        let deletingTodoItem = fileCache.todoItems.value[indexPath.row]
        fileCache.delete(deletingTodoItem.id)
    }
}

// MARK: Data source
extension ListViewModel {
    func getTodoItem(for indexPath: IndexPath) -> TodoItem {
        isFilteredWithoutCompletedItems
        ? uncompletedTodoItems[indexPath.row]
        : fileCache.todoItems.value[indexPath.row]
    }

    func getNumberOfRows() -> Int {
        isFilteredWithoutCompletedItems
        ? uncompletedTodoItems.count
        : fileCache.todoItems.value.count
    }

    func getCompletedTodoItemsCount() -> Int {
        fileCache.todoItems.value.filter { $0.isDone }.count
    }
}
