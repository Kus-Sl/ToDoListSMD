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
    var deadLine: Box<Date?> { get set }
    var delegate: DetailViewControllerDelegate! { get set }

    init(todoItem: TodoItem)

    func deleteTodoItem()
    func saveTodoItem()

    func getCellID(_ indexPath: IndexPath) -> String
    func getNumberOfRows() -> Int
    func getHeightForRows(_ indexPath: IndexPath) -> Double

    func changedImportanceControl(to index: ImportanceCell.SegmentedControlIndexes)
    func setImportanceControl() -> Int
    func isDeadlineExist() -> Bool
    func changedSwitchControl(to status: Bool)
    func showOrHideDatePicker()

}

final class DetailViewModel: DetailViewModelProtocol {
    var text: String
    var importance: Importance
    var deadLine: Box<Date?>
    var delegate: DetailViewControllerDelegate!

    // NB: доковырять
    private let todoItem: TodoItem
    private lazy var isHiddenDatePicker = true
    private lazy var fileCache = FileCache()
    private lazy var cellTypes: [CellType] = [.importance, .deadLine]

    required init(todoItem: TodoItem) {
        self.todoItem = todoItem
        text = todoItem.text
        importance = todoItem.importance
        deadLine = Box(value: todoItem.deadLine)
    }

    func deleteTodoItem() {
        fileCache.delete(todoItem.id)
    }

    func saveTodoItem() {
        let newTodoItem = TodoItem(
            id: todoItem.id,
            text: text,
            importance: importance,
            isDone: todoItem.isDone,
            creationDate: todoItem.creationDate,
            changeDate: Date(),
            deadLine: deadLine.value
        )

        do {
            try fileCache.add(newTodoItem)
        } catch {
            //NB: Показать алерт
        }
    }
}

// MARK: Cell's data source
extension DetailViewModel {
    func getCellID(_ indexPath: IndexPath) -> String {
        cellTypes[indexPath.row].getClass().cellReuseIdentifier()
    }

    func getNumberOfRows() -> Int {
        cellTypes.count
    }

    func getHeightForRows(_ indexPath: IndexPath) -> Double {
        cellTypes[indexPath.row].getHeight()
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
        deadLine.value != nil
    }

    func changedSwitchControl(to status: Bool) {
        deadLine.value = status
        ? Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        : nil

        if !isHiddenDatePicker && deadLine.value == nil {
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
