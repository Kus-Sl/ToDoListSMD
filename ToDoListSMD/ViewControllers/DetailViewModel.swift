//
//  DetailViewModelProtocol.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 02.08.2022.
//

import UIKit
import Foundation

protocol DetailViewModelProtocol {
    var numberOfRows: Int { get }
    var heightForRows: Double { get }
    var cellID: String { get }

    var text: String { get }

    func save(_ indexPath: IndexPath)
    func cellViewModel() -> CellViewModelProtocol

    init(todoItem: TodoItem)
}

final class DetailViewModel: DetailViewModelProtocol {
    let cellTypes: [CellType] = [.importance, .deadLine, .calendar] // доковырять
    let numberOfRows = 3

    var heightForRows: Double {
        cellTypes[indexPath.row].getHeight()
    }

    var text: String {
        todoItem.text
    }

    var cellID: String {
        cellTypes[indexPath.row].getClass().cellReuseIdentifier()
    }

    private let todoItem: TodoItem!
    private var indexPath: IndexPath!

    required init(todoItem: TodoItem) {
        self.todoItem = todoItem
    }

    func save(_ indexPath: IndexPath) {
        self.indexPath = indexPath
    }

    func cellViewModel() -> CellViewModelProtocol {
        let cellTitle = cellTypes[indexPath.row].getTitle()
        return CellViewModel(for: todoItem, with: cellTitle)
    }
}
