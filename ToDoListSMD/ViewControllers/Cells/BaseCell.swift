//
//  BaseCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 30.07.2022.
//

import UIKit

class BaseCell: UITableViewCell {
    var delegate: CustomControlsDelegate!

    func configure(with title: String, and secondaryTitle: String?) {
        backgroundColor = UIColor.colorAssets.backSecondary

        var content = defaultContentConfiguration()
        content.textProperties.color = UIColor.colorAssets.labelPrimary!
        content.secondaryTextProperties.color = UIColor.colorAssets.colorBlue!
        content.textProperties.font = UIFont.systemFont(ofSize: 17)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 13)
        content.text = title
        content.secondaryText = secondaryTitle
        contentConfiguration = content
    }

    func addControl() {}

    class func cellReuseIdentifier() -> String {
        "\(self)"
    }
}

enum CellType {
    case importance
    case deadLine
    case calendar

    func getHeight() -> CGFloat {
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
