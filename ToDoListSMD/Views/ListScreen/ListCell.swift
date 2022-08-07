//
//  ListCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 07.08.2022.
//

import UIKit

final class ListCell: UITableViewCell {
    private var todoItem: TodoItem!
    private var viewModel: ListViewModelProtocol!

    private lazy var content = defaultContentConfiguration()

    func configure(for indexPath: IndexPath, with viewModel: ListViewModelProtocol) {
        self.viewModel = viewModel
        todoItem = viewModel.getTodoItem(for: indexPath)
        setupContent()
    }

    private func setupContent() {
        backgroundColor = .ColorAsset.backSecondary
        content.textProperties.numberOfLines = Constants.numberOfLines
        
        todoItem.isDone
        ? setupContentForCompletedTodoItem()
        : checkTodoItemDeadLine()

        accessoryView = UIImageView(image: .IconAsset.listCellDirectionIcon)
        contentConfiguration = content
    }

    private func checkTodoItemDeadLine() {
        guard let deadLine = todoItem.deadLine else {
            setupContentForUncompletedTodoItemWithoutDeadLine()
            return
        }

        deadLine <= Date()
        ? setupContentForExpiredTodoItem()
        : setupContentForUncompletedTodoItemWithDeadLine()
    }

    private func setupContentForCompletedTodoItem() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.FontAsset.body,
            .foregroundColor: UIColor.ColorAsset.labelTertiary!,
            .strikethroughStyle: Constants.strikethroughStyleValue
        ]

        content.attributedText = NSAttributedString(string: todoItem.text, attributes: attributes)
        content.image = .IconAsset.listCellCheckmarkDoneIcon
    }

    private func setupContentForUncompletedTodoItemWithoutDeadLine() {
        content.textProperties.color = .ColorAsset.labelPrimary!
        content.text = todoItem.text
        content.image = .IconAsset.listCellCheckmarkIcon
    }

    private func setupContentForUncompletedTodoItemWithDeadLine() {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = .IconAsset.listCellDeadlineIcon

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.FontAsset.subhead,
            .foregroundColor: UIColor.ColorAsset.labelTertiary!,
            .attachment: imageAttachment
        ]

        if let deadline = todoItem.deadLine {
            content.secondaryAttributedText = NSAttributedString(string: DateFormatter.formatter.string(from: deadline), attributes: attributes)
        }


        content.text = todoItem.text
        content.image = .IconAsset.listCellCheckmarkIcon
    }

    private func setupContentForExpiredTodoItem() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.FontAsset.body,
            .foregroundColor: UIColor.ColorAsset.labelPrimary!
        ]

        content.attributedText = NSMutableAttributedString(string: todoItem.text, attributes: attributes)
        content.image = .IconAsset.listCellCheckmarkExpiredIcon
    }
}

//MARK: Constants
extension ListCell {
    private enum Constants {
        static let strikethroughStyleValue = 1
        static let numberOfLines = 3
    }
}
