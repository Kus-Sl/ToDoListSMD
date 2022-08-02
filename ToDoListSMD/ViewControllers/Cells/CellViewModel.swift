//
//  BaseCellViewModel.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 02.08.2022.
//

import Foundation

protocol CellViewModelProtocol {
    var title: String { get }

    var importance: Importance? { get }
    var deadLine: Date? { get }

    init(for todoItem: TodoItem, with title: String)
}

class CellViewModel: CellViewModelProtocol {
    let title: String

    var importance: Importance? {
        todoItem.importance
    }

    var deadLine: Date? {
        todoItem.deadLine
    }

    private let todoItem: TodoItem
    
    required init(for todoItem: TodoItem, with title: String) {
        self.todoItem = todoItem
        self.title = title
    }
}
