//
//  CellType.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 05.08.2022.
//

import Foundation
import UIKit.UITableView

enum CellType {
    case importance
    case deadline
    case calendar

    func getRowIndexPath() -> IndexPath {
        switch self {
        case .importance:
            return Constants.importanceCellIndexPath
        case .deadline:
            return Constants.deadlineCellIndexPath
        case .calendar:
            return Constants.calendarCellIndexPath
        }
    }

    func getHeight() -> Double {
        switch self {
        case .importance, .deadline:
            return Constants.importanceAndDeadlineCellHeight
        case .calendar:
            return UITableView.automaticDimension
        }
    }

    func getTitle() -> String {
        switch self {
        case .importance:
            return Constants.importanceLabelTitle
        case .deadline:
            return Constants.deadlineLabelTitle
        case .calendar:
            return Constants.calendarLabelTitle
        }
    }

    func getClass() -> BaseCell.Type{
        switch self {
        case .importance:
            return ImportanceCell.self
        case .deadline:
            return DeadlineCell.self
        case .calendar:
            return CalendarCell.self
        }
    }

    private enum Constants {
        static let importanceLabelTitle = "Важность"
        static let deadlineLabelTitle = "Сделать до"
        static let calendarLabelTitle = ""
        static let importanceAndDeadlineCellHeight: Double = 58
        static let importanceCellIndexPath: IndexPath = IndexPath(row: 0, section: 0)
        static let deadlineCellIndexPath: IndexPath = IndexPath(row: 1, section: 0)
        static let calendarCellIndexPath: IndexPath = IndexPath(row: 2, section: 0)
    }
}
