//
//  DetailViewModelProtocol.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 02.08.2022.
//

import Foundation
import CocoaLumberjack
import Helpers

protocol DetailViewModelProtocol {
    var text: String { get }
    var importance: Importance { get }
    var deadline: Box<Int?> { get set }

    func assignDelegate(_ delegate: DetailViewModelDelegate)

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

protocol DetailViewModelDelegate: AnyObject {
    func showDatePicker()
    func hideDatePicker()
    func animateDatePicker()
    func getText() -> String
}

final class DetailViewModel: DetailViewModelProtocol {
    // NB: оптимизировать
    var text: String
    var importance: Importance
    var deadline: Box<Int?>
    weak var delegate: DetailViewModelDelegate?

    // NB: доковырять
    private let todoItem: TodoItem
    private let todoService: TodoServiceProtocol
    private var isNewTodoItem: Bool
    private lazy var isHiddenDatePicker = true
    private lazy var cellTypes: [CellType] = [.importance, .deadline]

    init(_ todoItem: TodoItem, _ todoService: TodoServiceProtocol) {
        self.todoItem = todoItem
        self.todoService = todoService
        text = todoItem.text
        importance = Importance(rawValue: todoItem.importance) ?? Importance.ordinary
        deadline = Box(value: todoItem.deadline)

        isNewTodoItem = todoItem.text.isEmpty
    }

    func assignDelegate(_ delegate: DetailViewModelDelegate) {
        self.delegate = delegate
    }
}

// MARK: Actions
extension DetailViewModel {
    func deleteTodoItem() {
        todoService.delete(todoItem.id) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                DDLogInfo(error)
                // NB: обработать
            }
        }
    }

    func saveOrUpdateTodoItem() {
        let newTodoItem = TodoItem(
            id: todoItem.id,
            text: delegate?.getText() ?? "",
            importance: importance.rawValue,
            isDone: todoItem.isDone,
            creationDate: todoItem.creationDate,
            changeDate: Int(Date().timeIntervalSince1970),
            deadline: deadline.value,
            isDirty: todoItem.isDirty
        )

        isNewTodoItem ? save(newTodoItem) : update(newTodoItem)
    }

    private func save(_ newTodoItem: TodoItem) {
        todoService.add(newTodoItem) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                DDLogInfo(error)
                // NB: обработать
            }
        }
    }

    private func update(_ updatingTodoItem: TodoItem) {
        todoService.update(updatingTodoItem) { result in
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
        ? Int((Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()).timeIntervalSince1970)
        : nil

        if !isHiddenDatePicker && deadline.value == nil {
            showOrHideDatePicker()
        }
    }

    func showOrHideDatePicker() {
        isHiddenDatePicker
        ? showDatePicker()
        : hideDatePicker()

        delegate?.animateDatePicker()
        isHiddenDatePicker.toggle()
    }

    private func showDatePicker() {
        cellTypes.append(.calendar)
        delegate?.showDatePicker()
    }

    private func hideDatePicker() {
        cellTypes.removeLast()
        delegate?.hideDatePicker()
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
