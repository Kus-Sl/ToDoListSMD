//
//  CalendarCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 29.07.2022.
//

import UIKit

final class CalendarCell: BaseCell{
    override func configure(for todoItem: TodoItem?, with title: String) {
        backgroundColor = UIColor.colorAssets.backSecondary
        separatorInset.right = .greatestFiniteMagnitude
        self.todoItem = todoItem
    }

    override func addControl() {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date

        if let deadLine = todoItem?.deadLine {
            datePicker.date = deadLine
        } else {
            datePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        }

        contentView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        endContentConfigure()
    }
}
