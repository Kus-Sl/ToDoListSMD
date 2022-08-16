//
//  ListCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 07.08.2022.
//

import UIKit
import CocoaLumberjack

final class ListCell: UITableViewCell {
    private var todoItem: TodoItem!
    private var content: UIListContentConfiguration?

    override func prepareForReuse() {
        contentConfiguration = nil
    }

    func configure(with todoItem: TodoItem) {
        self.todoItem = todoItem
        setupContent()
    }

    private func setupContent() {
        backgroundColor = .ColorAsset.backSecondary
        content = defaultContentConfiguration()
        content?.textProperties.numberOfLines = Constants.numberOfLines

        setupCheckmarkIcon()
        setupText()
        setupSecondaryText()

        accessoryView = UIImageView(image: .IconAsset.listCellDirectionIcon)
        contentConfiguration = content
    }

    private func setupCheckmarkIcon() {
        guard !todoItem.isDone else {
            content?.image = .IconAsset.listCellCheckmarkDoneIcon
            return
        }

        guard let deadline = todoItem.deadline, Date(timeIntervalSince1970: TimeInterval(deadline)) <= Date() else {
            content?.image = .IconAsset.listCellCheckmarkIcon
            return
        }

        content?.image = .IconAsset.listCellCheckmarkExpiredIcon
    }

    private func setupText() {
        var attributesForText: [NSAttributedString.Key: Any] = [.font: UIFont.FontAsset.body]

        guard !todoItem.isDone else {
            attributesForText[.foregroundColor] = UIColor.ColorAsset.labelTertiary
            attributesForText[.strikethroughStyle] = Constants.strikethroughStyleValue

            content?.attributedText = NSAttributedString(string: todoItem.text, attributes: attributesForText)
            return
        }

        guard todoItem.importance != .important else {
            let textIcon = UIImage.IconAsset.importantSegmentedControlIcon
            let textAttachmentIcon = NSTextAttachment(image: textIcon)
            let attributedStringWithIcon = NSAttributedString(attachment: textAttachmentIcon)

            attributesForText[.foregroundColor] = UIColor.ColorAsset.labelPrimary
            let textString = NSMutableAttributedString(string: " \(todoItem.text)", attributes: attributesForText)

            textString.insert(attributedStringWithIcon, at: Constants.firstIndex)
            content?.attributedText = textString
            return
        }

        content?.textProperties.color = .ColorAsset.labelPrimary
        content?.text = todoItem.text
    }

    private func setupSecondaryText() {
        guard let deadline = todoItem.deadline, !todoItem.isDone else { return }

        let secondaryTextIcon = UIImage.IconAsset.listCellDeadlineIcon
        let secondaryTextAttachmentIcon = NSTextAttachment(image: secondaryTextIcon)
        let attributedStringWithIcon = NSAttributedString(attachment: secondaryTextAttachmentIcon)

        let attributesForSecondaryText: [NSAttributedString.Key: Any] = [
            .font: UIFont.FontAsset.subhead,
            .foregroundColor: UIColor.ColorAsset.labelTertiary
        ]

        let stringDate = DateFormatter.formatter.string(from: Date(timeIntervalSince1970: TimeInterval(deadline)))
        let attributedStringWithDate = NSAttributedString(string: stringDate, attributes: attributesForSecondaryText)
        let secondaryTextString = NSMutableAttributedString(string: "", attributes: attributesForSecondaryText)
        secondaryTextString.append(attributedStringWithIcon)
        secondaryTextString.append(attributedStringWithDate)
        content?.secondaryAttributedText = secondaryTextString
    }
}

// MARK: Constants
extension ListCell {
    private enum Constants {
        static let strikethroughStyleValue = 1
        static let numberOfLines = 3
        static let firstIndex = 0
    }
}
