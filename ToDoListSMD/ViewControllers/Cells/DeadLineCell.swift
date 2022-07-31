//
//  DeadLineCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 29.07.2022.
//

import UIKit

final class DeadLineCell: BaseCell {
    override func addControl() {
        let control = UISwitch()
        control.addTarget(self, action: #selector(addCalendar), for: .valueChanged)

        if let deadLine = todoItem?.deadLine {
//            control.isOn = true
            content.secondaryText = DateFormatter.formatter.string(from: deadLine)
        }

        accessoryView = control
        endContentConfigure()
    }

    @objc func addCalendar(sender: UISwitch) {
        if sender.isOn {
            separatorInset.right = 16
            delegate.showCalendar()
        } else {
            separatorInset.right = .greatestFiniteMagnitude
            delegate.closeCalendar()
        }
    }
}
