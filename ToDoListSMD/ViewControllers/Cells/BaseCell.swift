//
//  BaseCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 30.07.2022.
//

import UIKit

class BaseCell: UITableViewCell {
    var content: UIListContentConfiguration!

    var viewModel: DetailViewModelProtocol! {
        didSet {
            setupContent()
            setupControl()
        }
    }

    func setupContent() {
        backgroundColor = UIColor.colorAssets.backSecondary
        content = defaultContentConfiguration()
        content.textProperties.color = UIColor.colorAssets.labelPrimary!
        content.textProperties.font = UIFont.systemFont(ofSize: 17)
    }

    func setupControl() {}

    class func cellReuseIdentifier() -> String {
        self.description()
    }
}




enum CellType {
    case importance
    case deadLine
    case calendar

    func getHeight() -> Double {
        switch self {
        case .importance, .deadLine:
            return 58
        case .calendar:
            return UITableView.automaticDimension
        }
    }

    func getTitle() -> String {
        switch self {
        case .importance:
            return "Важность"
        case .deadLine:
            return "Сделать до"
        case .calendar:
            return ""
        }
    }

    func getClass() -> BaseCell.Type{
        switch self {
        case .importance:
            return ImportanceCell.self
        case .deadLine:
            return DeadLineCell.self
        case .calendar:
            return CalendarCell.self
        }
    }
}
