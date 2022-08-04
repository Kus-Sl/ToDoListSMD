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

    func changedImportanceControl(to index: Int)
    func setImportanceControl() -> Int
    func changedSwitchControl(to status: Bool)
    func setSwitchControl() -> Bool 

    init(for todoItem: TodoItem, with title: String)
}

final class CellViewModel: CellViewModelProtocol {
    let title: String
    var importance: Importance?
    var deadLine: Date?

    required init(for todoItem: TodoItem, with title: String) {
        self.title = title
        importance = todoItem.importance
        deadLine = todoItem.deadLine
    }

    func changedImportanceControl(to index: Int) {
        switch index {
        case 0:
            importance = .unimportant
        case 1:
            importance = .ordinary
        default:
            importance = .important
        }
    }

    func setImportanceControl() -> Int {
        switch importance {
        case .important:
           return 2
        case .ordinary, .none:
           return 1
        case .unimportant:
           return 0
        }
    }

    func changedSwitchControl(to status: Bool) {
        if status {
            deadLine = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        } else {
            deadLine = nil
        }
    }

    func setSwitchControl() -> Bool {
        deadLine != nil
    }
}
