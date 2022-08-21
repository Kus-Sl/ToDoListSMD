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

    func assignTodoServiceDelegate(_ delegate: TodoServiceDelegate)

    func createDetailViewModel(for indexPath: IndexPath?) -> DetailViewModel
    func completeTodoItem(with indexPath: IndexPath)
    func deleteTodoItem(with indexPath: IndexPath)
    
    func getNumberOfRows() -> Int
    func getTodoItem(for indexPath: IndexPath) -> TodoItem
    func getCompletedTodoItemsCount() -> Int
}

final class ListViewModel: ListViewModelProtocol {
    var isFilteredWithoutCompletedItems = false
    private let todoService: TodoServiceProtocol
    
    private var uncompletedTodoItems: [TodoItem] {
        todoService.threadSafeTodoItems.filter { !$0.isDone }
    }

    init(_ todoService: TodoServiceProtocol) {
        self.todoService = todoService
    }

    func assignTodoServiceDelegate(_ delegate: TodoServiceDelegate) {
        todoService.assignDelegate(delegate)
    }
}

// MARK: Actions
extension ListViewModel {
    func createDetailViewModel(for indexPath: IndexPath?) -> DetailViewModel {
        guard let indexPath = indexPath else {
            return DetailViewModel(TodoItem(text: ""), todoService)
        }

        return DetailViewModel(getTodoItem(for: indexPath), todoService)
    }

    func completeTodoItem(with indexPath: IndexPath) {
        let completedTodoItem = todoService.threadSafeTodoItems[indexPath.row].asCompleted
        todoService.update(completedTodoItem) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                DDLogInfo(error)
                // NB: обработать
            }
        }
    }
    
    func deleteTodoItem(with indexPath: IndexPath) {
        let deletingTodoItem = todoService.threadSafeTodoItems[indexPath.row]
        todoService.delete(deletingTodoItem.id) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                DDLogInfo(error)
                // NB: обработать
            }
        }
    }
}

// MARK: Data source
extension ListViewModel {
    func getTodoItem(for indexPath: IndexPath) -> TodoItem {
        isFilteredWithoutCompletedItems
        ? uncompletedTodoItems[indexPath.row]
        : todoService.threadSafeTodoItems[indexPath.row]
    }
    
    func getNumberOfRows() -> Int {
        isFilteredWithoutCompletedItems
        ? uncompletedTodoItems.count
        : todoService.threadSafeTodoItems.count
    }
    
    func getCompletedTodoItemsCount() -> Int {
        todoService.threadSafeTodoItems.filter { $0.isDone }.count
    }
}
