//
//  DeadlineCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 29.07.2022.
//

import UIKit
import CocoaLumberjack

final class DeadlineCell: BaseCell {
    private var deadlineButton: UIButton?
    private lazy var switchControl = UISwitch()
    private lazy var titleLabel = UILabel()
    private lazy var deadlineButtonConstraints: [NSLayoutConstraint] = []
    private lazy var titleLabelTopConstraint = NSLayoutConstraint()

    override func setupContent() {
        super.setupContent()
        addTitleLabel()
        
        if viewModel.isDeadlineExist() {
            showDeadlineButton()
        }
    }

    override func setupControl() {
        switchControl.isOn = viewModel.isDeadlineExist()
        switchControl.addTarget(self, action: #selector(switchControlChanged), for: .valueChanged)
        accessoryView = switchControl
    }

    private func addTitleLabel() {
        titleLabel.textColor = .ColorAsset.labelPrimary
        titleLabel.font = .FontAsset.body
        titleLabel.text = CellType.deadline.getTitle()

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.widthAnchor.constraint(equalToConstant: Constants.titleLabelWidth).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.titleLabelLeadingInset).isActive = true
        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.titleLabelTopInset)
        titleLabelTopConstraint.isActive = true
    }
}

// MARK: Actions
extension DeadlineCell {
    @objc private func switchControlChanged(target: UISwitch) {
        viewModel.changedSwitchControl(to: target.isOn)
        showOrHideDeadlineButton(accordingTo: target.isOn)
    }

    @objc private func deadlineButtonTapped() {
        viewModel.showOrHideDatePicker()
    }

    private func showDeadlineButton() {
        deadlineButton = UIButton()
        guard let deadlineButton = deadlineButton else { return }

        deadlineButton.setTitleColor(.ColorAsset.colorBlue, for: .normal)
        deadlineButton.titleLabel?.font = .FontAsset.footnote
        viewModel.deadline.bind { date in
            guard let date = date else { return }
            deadlineButton.setTitle(DateFormatter.formatter.string(from: Date(timeIntervalSince1970: TimeInterval(date))), for: .normal)
        }
        deadlineButton.addTarget(self, action: #selector(deadlineButtonTapped), for: .touchUpInside)

        contentView.addSubview(deadlineButton)
        deadlineButton.translatesAutoresizingMaskIntoConstraints = false

        deadlineButtonConstraints = [
            deadlineButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            deadlineButton.heightAnchor.constraint(equalToConstant: Constants.deadlineButtonHeight),
            deadlineButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.deadlineButtonLeadingInset)
        ]

        NSLayoutConstraint.activate(deadlineButtonConstraints)
        titleLabelTopConstraint.constant = Constants.titleLabelTopInsetWithDeadlineButton
    }

    private func hideDeadlineButton() {
        NSLayoutConstraint.deactivate(deadlineButtonConstraints)
        titleLabelTopConstraint.constant = Constants.titleLabelTopInset
        deadlineButton?.removeFromSuperview()
        deadlineButton = nil
    }

    private func showOrHideDeadlineButton(accordingTo status: Bool) {
        status ? showDeadlineButton() : hideDeadlineButton()
    }
}

// MARK: Constants
extension DeadlineCell {
    private enum Constants {
        static let titleLabelTopInset: CGFloat = 17
        static let titleLabelTopInsetWithDeadlineButton: CGFloat = 9
        static let titleLabelLeadingInset: CGFloat = 16
        static let titleLabelWidth: CGFloat = 91
        static let deadlineButtonHeight: CGFloat = 18
        static let deadlineButtonLeadingInset: CGFloat = 18
    }
}
