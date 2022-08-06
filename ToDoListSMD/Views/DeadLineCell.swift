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
        
        if viewModel.isDeadlineExist() {
            showDeadLineButton()
        }
    }

    override func setupControl() {
        switchControl.isOn = viewModel.isDeadlineExist()
        switchControl.addTarget(self, action: #selector(switchControlChanged), for: .valueChanged)
        accessoryView = switchControl
    }

    private func addTitleLabel() {
        titleLabel.textColor = UIColor.colorAssets.labelPrimary
        titleLabel.font = UIFont.body
        titleLabel.text = CellType.deadLine.getTitle()

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.widthAnchor.constraint(equalToConstant: Constants.titleLabelWidth).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.titleLabelLeadingInset).isActive = true
        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.titleLabelTopInset)
        titleLabelTopConstraint.isActive = true
    }
}

//MARK: Actions
extension DeadLineCell {
    @objc private func switchControlChanged(target: UISwitch) {
        viewModel.changedSwitchControl(to: target.isOn)
        showOrHideDatePickerButton(accordingTo: target.isOn)
    }

    @objc private func showOrHideDatePicker() {
        viewModel.showOrHideDatePicker()
    }

    private func showDeadLineButton() {
        datePickerButton = UIButton()
        guard let datePickerButton = datePickerButton else { return }

        datePickerButton.setTitleColor(UIColor.colorAssets.colorBlue, for: .normal)
        datePickerButton.titleLabel?.font = UIFont.footnote
        viewModel.deadLine.bind { date in
            datePickerButton.setTitle(DateFormatter.formatter.string(from: date ?? Date()), for: .normal)
        }
        datePickerButton.addTarget(self, action: #selector(showOrHideDatePicker), for: .touchUpInside)

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

    private func hideDeadLineButton() {
        NSLayoutConstraint.deactivate(datePickerButtonConstraints)
        titleLabelTopConstraint.constant = Constants.titleLabelTopInset
        datePickerButton?.removeFromSuperview()
        datePickerButton = nil
    }

    private func showOrHideDatePickerButton(accordingTo status: Bool) {
        status ? showDeadLineButton() : hideDeadLineButton()
    }
}

//MARK: Constants
extension DeadLineCell {
    private enum Constants {
        static let titleLabelTopInset: CGFloat = 17
        static let titleLabelTopInsetWithDatePickerButton: CGFloat = 9
        static let titleLabelLeadingInset: CGFloat = 16
        static let titleLabelWidth: CGFloat = 91
        static let datePickerButtonHeight: CGFloat = 18
        static let datePickerButtonLeadingInset: CGFloat = 18
    }
}
