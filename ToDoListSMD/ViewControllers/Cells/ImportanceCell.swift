//
//  ImportanceCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 28.07.2022.
//

import UIKit

final class ImportanceCell: BaseCell {
    private var control = UISegmentedControl()

    override func setupContent() {
        super.setupContent()
        content.text = "Важность"
        contentConfiguration = content
    }

    override func setupControl() {
        control.frame = CGRect(x: 0, y: 0, width: 150, height: 36)
        control.insertSegment(with: UIImage(named: "custom.arrow.down"), at: 0, animated: true)
        control.insertSegment(withTitle: "нет", at: 1, animated: true)
        control.insertSegment(with: UIImage(named: "custom.exclamationmark.2"), at: 2, animated: true)
        control.addTarget(self, action: #selector(controlChanged), for: .valueChanged)
        control.selectedSegmentIndex = viewModel.setImportanceControl()

        accessoryView = control
    }

    @objc func controlChanged(target: UISegmentedControl) {
        viewModel.changedImportanceControl(to: target.selectedSegmentIndex)
    }
}
