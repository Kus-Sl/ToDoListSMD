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

    func assignListViewModelDelegate(_ delegate: ListViewModelDelegate)

    func createDetailViewModel(for indexPath: IndexPath?) -> DetailViewModel
    func completeTodoItem(with indexPath: IndexPath)
    func deleteTodoItem(with indexPath: IndexPath)
    
    func getNumberOfRows() -> Int
    func getTodoItem(for indexPath: IndexPath) -> TodoItem
    func getCompletedTodoItemsCount() -> Int
}

protocol ListViewModelDelegate: AnyObject {
    func startSpinner()
    func stopSpinner()
    func reloadTableView()
}

final class ListViewModel: ListViewModelProtocol {
    var isFilteredWithoutCompletedItems = false

    private let todoService: TodoServiceProtocol
    private weak var delegate: ListViewModelDelegate?
    
    private var uncompletedTodoItems: [TodoItem] {
        todoService.threadSafeTodoItems.filter { !$0.isDone }
    }

    init(_ todoService: TodoServiceProtocol) {
        self.todoService = todoService
        todoService.assignDelegate(self)
    }

    func assignListViewModelDelegate(_ delegate: ListViewModelDelegate) {
        self.delegate = delegate
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
        todoService.update(completedTodoItem)
    }
    
    func deleteTodoItem(with indexPath: IndexPath) {
        let deletingTodoItem = todoService.threadSafeTodoItems[indexPath.row]
        todoService.delete(deletingTodoItem.id)        }
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

// MARK: TodoService delegate
extension ListViewModel: TodoServiceDelegate {
    func todoItemsChanged() {
        delegate?.reloadTableView()
    }

    func requestStarted() {
        delegate?.startSpinner()
    }

    func requestEnded() {
        delegate?.stopSpinner()
    }
}
