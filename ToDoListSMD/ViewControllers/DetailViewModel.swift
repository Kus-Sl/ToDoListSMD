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

    func changedImportanceControl(to index: ImportanceCell.SegmentedControlIndexes)
    func setImportanceControl() -> Int
    func changedSwitchControl(to status: Bool)
    func setSwitchControl() -> Bool
    func showOrHideDatePicker() -> Bool

    init(todoItem: TodoItem)
}

final class DetailViewModel: DetailViewModelProtocol {
    var text: String
    var importance: Importance
    var deadLine: Date?

    private var datePickerIsHidden = true

    // NB: доковырять
    private var cellTypes: [CellType] = [.importance, .deadLine]

    required init(todoItem: TodoItem) {
        text = todoItem.text
        importance = todoItem.importance
        deadLine = todoItem.deadLine
    }
}

// MARK: Cell's controls methods
extension DetailViewModel {
    func changedImportanceControl(to index: ImportanceCell.SegmentedControlIndexes) {
        switch index {
        case .unimportant:
            importance = .unimportant
        case .ordinary:
            importance = .ordinary
        case .important:
            importance = .important
        }
    }

    func setImportanceControl() -> Int {
        switch importance {
        case .unimportant:
            return ImportanceCell.SegmentedControlIndexes.unimportant.rawValue
        case .ordinary:
            return ImportanceCell.SegmentedControlIndexes.ordinary.rawValue
        case .important:
            return ImportanceCell.SegmentedControlIndexes.unimportant.rawValue
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

    func showOrHideDatePicker() -> Bool {
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
