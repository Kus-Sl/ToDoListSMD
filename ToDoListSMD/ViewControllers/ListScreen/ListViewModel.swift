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
    private let todoService: TodoServiceProtocol

    private var uncompletedTodoItems: [TodoItem] {
        todoService.todoItems.value.filter { !$0.isDone }
    }

    init(_ todoService: TodoServiceProtocol) {
        self.todoService = todoService
    }

    func bindViewControllerWithModel(_ listener: @escaping ([TodoItem]) -> ()) {
        todoService.todoItems.listener = listener
    }

    func createDetailViewModel(for indexPath: IndexPath?) -> DetailViewModel {
        guard let indexPath = indexPath else {
            return DetailViewModel(TodoItem(text: ""), todoService)
        }
        
        return DetailViewModel(getTodoItem(for: indexPath), todoService)
    }
}

// MARK: Actions
extension ListViewModel {
    func completeTodoItem(with indexPath: IndexPath) {
        let completedTodoItem = todoService.todoItems.value[indexPath.row].asCompleted
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
        let deletingTodoItem = todoService.todoItems.value[indexPath.row]
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
        : todoService.todoItems.value[indexPath.row]
    }
    
    func getNumberOfRows() -> Int {
        isFilteredWithoutCompletedItems
        ? uncompletedTodoItems.count
        : todoService.todoItems.value.count
    }
    
    func getCompletedTodoItemsCount() -> Int {
        todoService.todoItems.value.filter { $0.isDone }.count
    }
}
