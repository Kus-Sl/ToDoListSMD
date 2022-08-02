//
//  ImportanceCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 28.07.2022.
//

import UIKit

final class ImportanceCell: BaseCell {

    override func addControl() {
        let control = UISegmentedControl()
        control.frame = CGRect(x: 0, y: 0, width: 150, height: 36)
        control.insertSegment(with: UIImage(named: "custom.arrow.down"), at: 0, animated: true)
        control.insertSegment(withTitle: "нет", at: 1, animated: true)
        control.insertSegment(with: UIImage(named: "custom.exclamationmark.2"), at: 2, animated: true)

        if let importance = viewModel.importance {
            switch importance {
            case .important:
                control.selectedSegmentIndex = 2
            case .ordinary:
                control.selectedSegmentIndex = 1
            case .unimportant:
                control.selectedSegmentIndex = 0
            }
        } else {
            control.selectedSegmentIndex = 1
        }

        accessoryView = control
    }
}
