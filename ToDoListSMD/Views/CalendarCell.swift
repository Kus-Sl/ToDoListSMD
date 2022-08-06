//
//  CalendarCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 29.07.2022.
//

import UIKit

final class CalendarCell: BaseCell {
    private lazy var datePicker = UIDatePicker()

    override func setupContent() {
        super.setupContent()
        contentConfiguration = content
    }

    override func setupControl() {
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date

        if let deadLine = viewModel.deadLine {
            datePicker.date = deadLine
        } else {
            datePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        }

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
