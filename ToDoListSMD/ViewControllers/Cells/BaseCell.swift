//
//  BaseCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 30.07.2022.
//

import UIKit

class BaseCell: UITableViewCell {
    var viewModel: CellViewModelProtocol! {
        didSet {
            setupContent()
            content.text = viewModel.title
            contentConfiguration = content
            addControl()
        }
    }

    private var content: UIListContentConfiguration!

    func addControl() {}

    private func setupContent() {
        backgroundColor = UIColor.colorAssets.backSecondary
        content = defaultContentConfiguration()
        content.textProperties.color = UIColor.colorAssets.labelPrimary!
        content.secondaryTextProperties.color = UIColor.colorAssets.colorBlue!
        content.textProperties.font = UIFont.systemFont(ofSize: 17)
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 13)
    }

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
            return 500 //UITableView.automaticDimension
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
