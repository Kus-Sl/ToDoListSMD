//
//  ImportanceCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 28.07.2022.
//

import UIKit

final class ImportanceCell: BaseCell {
    private lazy var control = UISegmentedControl()
    
    override func setupContent() {
        super.setupContent()
        content.text = CellType.importance.getTitle()
        contentConfiguration = content
    }
    
    override func setupControl() {
        control.frame = CGRect(x: 0, y: 0, width: Constants.segmentedControlWidth, height: Constants.segmentedControlHeight)
        control.insertSegment(with: Constants.unimportantSegmentedControlImage, at: SegmentedControlIndexes.unimportant.rawValue, animated: true)
        control.insertSegment(withTitle: Constants.ordinarySegmentedControlTitle, at: SegmentedControlIndexes.ordinary.rawValue, animated: true)
        control.insertSegment(with: Constants.importantSegmentedControlImage, at: SegmentedControlIndexes.important.rawValue, animated: true)
        control.addTarget(self, action: #selector(controlChanged), for: .valueChanged)
        control.selectedSegmentIndex = viewModel.setImportanceControl()
        accessoryView = control
    }
}

//MARK: Actions
extension ImportanceCell {
    @objc func controlChanged(target: UISegmentedControl) {
        if let selectedIndex = SegmentedControlIndexes(rawValue: target.selectedSegmentIndex) {
            viewModel.changedImportanceControl(to: selectedIndex)
        }
    }
}

//MARK: Constants
extension ImportanceCell {
    enum SegmentedControlIndexes: Int {
        case unimportant = 0
        case ordinary = 1
        case important = 2
    }
    
    private enum Constants  {
        static let ordinarySegmentedControlTitle = "нет"
        static let importantSegmentedControlImage = UIImage(named: "custom.exclamationmark.2")
        static let unimportantSegmentedControlImage = UIImage(named: "custom.arrow.down")
        static let segmentedControlWidth = 150
        static let segmentedControlHeight = 36
    }
}
