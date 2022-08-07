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
        backgroundColor = UIColor.colorAsset.backSecondary

        todoItem.isDone
        ? setupContentForCompletedTodoItem()
        : checkTodoItemDeadLine()

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
            .font: UIFont.body,
            .foregroundColor: UIColor.colorAsset.labelTertiary!,
            .strikethroughStyle: 1
        ]

        content.textProperties.numberOfLines = 1
        content.attributedText = NSAttributedString(string: todoItem.text, attributes: attributes)
        content.image = UIImage.IconAsset.listCellCheckmerkDone
    }

    private func setupContentForUncompletedTodoItemWithoutDeadLine() {
        content.textProperties.numberOfLines = 3
        content.textProperties.color = UIColor.colorAsset.labelPrimary!
        content.text = todoItem.text
        content.image = UIImage.IconAsset.listCellCheckmerk
    }

    private func setupContentForUncompletedTodoItemWithDeadLine() {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage.IconAsset.listCellDeadlineCalendar

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.subhead,
            .foregroundColor: UIColor.colorAsset.labelTertiary!,
            .attachment: imageAttachment
        ]

        if let deadline = todoItem.deadLine {
            content.secondaryAttributedText = NSAttributedString(string: DateFormatter.formatter.string(from: deadline), attributes: attributes)
        }
        content.text = todoItem.text
        content.image = UIImage.IconAsset.listCellCheckmerk

    }

    private func setupContentForExpiredTodoItem() {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.body,
            .foregroundColor: UIColor.colorAsset.labelPrimary!
        ]

        content.textProperties.numberOfLines = 3
        content.attributedText = NSMutableAttributedString(string: todoItem.text, attributes: attributes)
        content.image = UIImage.IconAsset.listCellCheckmerkExpired
    }
}
