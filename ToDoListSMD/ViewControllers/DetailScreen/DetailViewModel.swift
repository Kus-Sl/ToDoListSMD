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
    var deadline: Box<Date?> { get set }
    var delegate: DetailViewControllerDelegate! { get set }

    func deleteTodoItem()
    func saveOrUpdateTodoItem()

    func changedImportanceControl(to index: ImportanceCell.SegmentedControlIndexes)
    func setImportanceControl() -> Int
    func isDeadlineExist() -> Bool
    func changedSwitchControl(to status: Bool)
    func showOrHideDatePicker()

    func getCellID(_ indexPath: IndexPath) -> String
    func getNumberOfRows() -> Int
    func getHeightForRows(_ indexPath: IndexPath) -> Double
}

final class DetailViewModel: DetailViewModelProtocol {
    // NB: оптимизировать
    var text: String
    var importance: Importance
    var deadline: Box<Date?>
    var delegate: DetailViewControllerDelegate!

    // NB: доковырять
    private let todoItem: TodoItem
    private let fileCache: FileCache
    private var isNewTodoItem: Bool
    private lazy var isHiddenDatePicker = true
    private lazy var cellTypes: [CellType] = [.importance, .deadline]

    required init(todoItem: TodoItem, fileCache: FileCache) {
        self.todoItem = todoItem
        self.fileCache = fileCache
        text = todoItem.text
        importance = todoItem.importance
        deadline = Box(value: todoItem.deadline)

        isNewTodoItem = todoItem.text.isEmpty
    }
}

// MARK: Actions
extension DetailViewModel {
    func deleteTodoItem() {
        fileCache.delete(todoItem.id)
    }

    func saveOrUpdateTodoItem() {
        let newTodoItem = TodoItem(
            id: todoItem.id,
            text: delegate.getText(),
            importance: importance,
            isDone: todoItem.isDone,
            creationDate: todoItem.creationDate,
            changeDate: Date(),
            deadline: deadline.value
        )

        isNewTodoItem ? save(newTodoItem) : update(newTodoItem)
    }

    private func save(_ newTodoItem: TodoItem) {
        do {
            try fileCache.add(newTodoItem)
        } catch {
            // NB: Показать алерт
        }
    }

    private func update(_ updatingTodoItem: TodoItem) {
        do {
            try fileCache.update(updatingTodoItem)
        } catch {
            // NB: Показать алерт
        }
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
            return ImportanceCell.SegmentedControlIndexes.important.rawValue
        }
    }

    func isDeadlineExist() -> Bool {
        deadline.value != nil
    }

    func changedSwitchControl(to status: Bool) {
        deadline.value = status
        ? Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        : nil

        if !isHiddenDatePicker && deadline.value == nil {
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

// MARK: Data source
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
