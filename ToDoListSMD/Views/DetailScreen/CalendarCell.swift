//
//  CalendarCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 29.07.2022.
//

import UIKit
import CocoaLumberjack

final class CalendarCell: BaseCell {
    private lazy var datePicker = UIDatePicker()

    override func setupContent() {
        super.setupContent()
        contentConfiguration = content
    }

    override func setupControl() {
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date

        guard let deadline = viewModel.deadline.value else { return }
        datePicker.date = Date(timeIntervalSince1970: TimeInterval(deadline))
        datePicker.addTarget(self, action: #selector(datePickerTapped), for: .valueChanged)

        setDatePickerConstraints()
    }

    private func setDatePickerConstraints() {
        contentView.addSubview(datePicker)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        contentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        datePicker.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

// MARK: Actions
extension CalendarCell {
    @objc private func datePickerTapped() {
        viewModel.deadline.value = Int(datePicker.date.timeIntervalSince1970)
    }
}
