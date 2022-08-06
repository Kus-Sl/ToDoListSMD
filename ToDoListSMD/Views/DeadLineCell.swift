//
//  DeadLineCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 29.07.2022.
//

import UIKit

final class DeadLineCell: BaseCell {
    private var datePickerButton: UIButton?
    private lazy var switchControl = UISwitch()
    private lazy var titleLabel = UILabel()
    private lazy var datePickerButtonConstraints: [NSLayoutConstraint] = []
    private lazy var titleLabelTopConstraint = NSLayoutConstraint()

    override func setupContent() {
        super.setupContent()
        addTitleLabel()

        if viewModel.deadLine != nil {
            addDeadLineButton()
        }
    }

    override func setupControl() {
        switchControl.isOn = viewModel.setSwitchControl()
        switchControl.addTarget(self, action: #selector(controlChanged), for: .valueChanged)

        accessoryView = switchControl
    }

    @objc func controlChanged(target: UISwitch) {
        viewModel.changedSwitchControl(to: target.isOn)
        showOrHideDatePickerButton(accordingTo: target.isOn)
    }

    private func addTitleLabel() {
        titleLabel.text = CellType.deadLine.getTitle()
        titleLabel.font = UIFont.body
        titleLabel.textColor = UIColor.colorAssets.labelPrimary

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.widthAnchor.constraint(equalToConstant: 91).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.titleLabelLeadingInset).isActive = true

        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.titleLabelTopInset)
        titleLabelTopConstraint.isActive = true
    }

    private func addDeadLineButton() {
        datePickerButton = UIButton()
        guard let datePickerButton = datePickerButton,
              let deadLine = viewModel.deadLine else {
            return
        }

        datePickerButton.titleLabel?.font = UIFont.footnote
        datePickerButton.setTitle(DateFormatter.formatter.string(from: deadLine), for: .normal)
        datePickerButton.setTitleColor(UIColor.colorAssets.colorBlue, for: .normal)

        contentView.addSubview(datePickerButton)
        datePickerButton.translatesAutoresizingMaskIntoConstraints = false

        datePickerButtonConstraints = [
            datePickerButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            datePickerButton.heightAnchor.constraint(equalToConstant: Constants.datePickerButtonHeight),
            datePickerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.datePickerButtonLeadingInset)
        ]

        NSLayoutConstraint.activate(datePickerButtonConstraints)
        titleLabelTopConstraint.constant = Constants.titleLabelTopInsetWithDatePickerButton
    }

    private func showOrHideDatePickerButton(accordingTo status: Bool) {
        if status {
            addDeadLineButton()
        } else {
            NSLayoutConstraint.deactivate(datePickerButtonConstraints)
            titleLabelTopConstraint.constant = Constants.titleLabelTopInset
            datePickerButton?.removeFromSuperview()
            datePickerButton = nil
        }
    }
}

extension DeadLineCell {
    private enum Constants {
        static let titleLabelTopInset: CGFloat = 17
        static let titleLabelTopInsetWithDatePickerButton: CGFloat = 9
        static let titleLabelLeadingInset: CGFloat = 16
        static let datePickerButtonHeight: CGFloat = 18
        static let datePickerButtonLeadingInset: CGFloat = 18
    }
}