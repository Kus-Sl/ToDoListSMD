//
//  DetailViewModelProtocol.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 02.08.2022.
//

import Foundation

protocol DetailViewModelProtocol {
    var text: String { get }
    var importance: Importance { get }
    var deadLine: Date? { get }

    func getCellID(_ indexPath: IndexPath) -> String
    func getNumberOfRows() -> Int
    func getHeightForRows(_ indexPath: IndexPath) -> Double

    func changedImportanceControl(to index: Int)
    func setImportanceControl() -> Int
    func changedSwitchControl(to status: Bool)
    func setSwitchControl() -> Bool

    init(todoItem: TodoItem)
}

final class DetailViewModel: DetailViewModelProtocol {
    private var cellTypes: [CellType] = [.importance, .deadLine] // доковырять
    private var datePickerIsHidden = true

    var text: String
    var importance: Importance
    var deadLine: Date?

    required init(todoItem: TodoItem) {
        text = todoItem.text
        importance = todoItem.importance
        deadLine = todoItem.deadLine
    }
}

// MARK: Cell's controls methods
extension DetailViewModel {
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
        case .ordinary:
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

    func showOrHideDatePicker() -> Bool{
        if datePickerIsHidden {
            cellTypes.append(.calendar)
        } else {
            cellTypes.removeLast()
        }
        datePickerIsHidden.toggle()
        return !datePickerIsHidden
    }
}

// MARK: Cell's data source
extension DetailViewModel {
    func getNumberOfRows() -> Int {
        cellTypes.count
    }

    func getCellID(_ indexPath: IndexPath) -> String {
        cellTypes[indexPath.row].getClass().cellReuseIdentifier()
    }

    func getHeightForRows(_ indexPath: IndexPath) -> Double {
        cellTypes[indexPath.row].getHeight()
    }
}
