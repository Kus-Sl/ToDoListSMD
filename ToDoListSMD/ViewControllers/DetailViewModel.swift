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
    var delegate: DetailViewControllerDelegate! { get set }

    func getCellID(_ indexPath: IndexPath) -> String
    func getNumberOfRows() -> Int
    func getHeightForRows(_ indexPath: IndexPath) -> Double

    func changedImportanceControl(to index: ImportanceCell.SegmentedControlIndexes)
    func setImportanceControl() -> Int
    func changedSwitchControl(to status: Bool)
    func isDeadlineExist() -> Bool
    func showOrHideDatePicker()

    init(todoItem: TodoItem)
}

final class DetailViewModel: DetailViewModelProtocol {
    var text: String
    var importance: Importance
    var deadLine: Date?

    var delegate: DetailViewControllerDelegate!

    // NB: доковырять
    private var isHiddenDatePicker = true
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

    func isDeadlineExist() -> Bool {
        deadLine != nil
    }

    func changedSwitchControl(to status: Bool) {
        deadLine = status
        ? Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        : nil

        if !isHiddenDatePicker && deadLine == nil {
            showOrHideDatePicker()
        }
    }

    func showOrHideDatePicker() {
        isHiddenDatePicker
        ? showDatePicker()
        : hideDatePicker()

        delegate.animateDatePicker()
        isHiddenDatePicker.toggle()
    }

    private func showDatePicker() {
        cellTypes.append(.calendar)
        delegate.showDatePicker()
    }

    private func hideDatePicker() {
        cellTypes.removeLast()
        delegate.hideDatePicker()
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
