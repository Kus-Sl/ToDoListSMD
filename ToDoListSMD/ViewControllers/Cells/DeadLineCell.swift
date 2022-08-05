//
//  DeadLineCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 29.07.2022.
//

import UIKit

final class DeadLineCell: BaseCell {
    private var control = UISwitch()

    override func setupContent() {
        super.setupContent()
        content.text = "Сделать до"
        contentConfiguration = content
    }

    override func setupControl() {
        control.isOn = viewModel.setSwitchControl()
        control.addTarget(self, action: #selector(controlChanged), for: .valueChanged)

        accessoryView = control
    }

    @objc func controlChanged(target: UISwitch) {
        viewModel.changedSwitchControl(to: target.isOn)
    }
}
