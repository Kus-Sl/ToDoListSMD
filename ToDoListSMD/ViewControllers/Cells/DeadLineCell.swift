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
        accessoryView = control
    }

//    @objc func addCalendar(sender: UISwitch) {
//        if sender.isOn {
//            separatorInset.right = 16
//            delegate.showCalendar()
//        } else {
//            separatorInset.right = .greatestFiniteMagnitude
//            delegate.closeCalendar()
//        }
//    }
}
