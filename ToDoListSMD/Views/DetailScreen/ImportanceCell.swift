//
//  ImportanceCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 28.07.2022.
//

import UIKit

final class ImportanceCell: BaseCell {
    private lazy var control = UISegmentedControl(items: [
        UIImage.IconAsset.unimportantSegmentedControlIcon as Any,
        Constants.ordinarySegmentedControlTitle as Any,
        UIImage.IconAsset.importantSegmentedControlIcon as Any
    ])
    
    override func setupContent() {
        super.setupContent()
        content.text = CellType.importance.getTitle()
        contentConfiguration = content
    }
    
    override func setupControl() {
        control.frame = CGRect(x: 0, y: 0, width: Constants.segmentedControlWidth, height: Constants.segmentedControlHeight)
        control.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        control.selectedSegmentIndex = viewModel.setImportanceControl()
        accessoryView = control
    }
}

// MARK: Actions
extension ImportanceCell {
    @objc func segmentedControlChanged(target: UISegmentedControl) {
        if let selectedIndex = SegmentedControlIndexes(rawValue: target.selectedSegmentIndex) {
            viewModel.changedImportanceControl(to: selectedIndex)
        }
    }
}

// MARK: Constants
extension ImportanceCell {
    enum SegmentedControlIndexes: Int {
        case unimportant = 0
        case ordinary = 1
        case important = 2
    }
    
    private enum Constants {
        static let ordinarySegmentedControlTitle = "нет"
        static let segmentedControlWidth = 150
        static let segmentedControlHeight = 36
    }
}
