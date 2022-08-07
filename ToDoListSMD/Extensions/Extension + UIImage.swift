//
//  Extension + UIImage.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 07.08.2022.
//

import Foundation
import UIKit

extension UIImage {
    enum IconAsset {
        static let importantSegmentedControlImage = UIImage(named: "custom.exclamationmark.2")
        static let unimportantSegmentedControlImage = UIImage(named: "custom.arrow.down")
        static let listCellDirectionArrow = UIImage(named: "custom.arrow.right")
        static let listCellCheckmerk = UIImage(named: "custom.checkmark.circle.gray")
        static let listCellCheckmerkDone = UIImage(named: "custom.checkmark.done")
        static let listCellCheckmerkExpired = UIImage(named: "custom.checkmark.circle.red")
        static let listCellDeadlineCalendar = UIImage(named: "custom.calendar")
    }
}
