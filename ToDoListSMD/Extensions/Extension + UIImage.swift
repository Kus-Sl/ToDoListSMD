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
        static let importantSegmentedControlIcon = UIImage(systemName: "exclamationmark.2")?.withTintColor(.ColorAsset.colorRed, renderingMode: .alwaysOriginal) ?? UIImage()
        static let unimportantSegmentedControlIcon = UIImage(systemName: "arrow.down")?.withTintColor(.ColorAsset.colorGray, renderingMode: .alwaysOriginal) ?? UIImage()
        static let listCellDirectionIcon = UIImage(systemName: "chevron.forward")?.withTintColor(.ColorAsset.colorGray, renderingMode: .alwaysOriginal) ?? UIImage()
        static let listCellCheckmarkIcon = UIImage(systemName: "circle")?.withTintColor(.ColorAsset.supportSeparator, renderingMode: .alwaysOriginal) ?? UIImage()
        static let listCellCheckmarkDoneIcon = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.ColorAsset.colorGreen, renderingMode: .alwaysOriginal) ?? UIImage()
        static let listCellCheckmarkExpiredIcon = UIImage(systemName: "circle")?.withTintColor(.ColorAsset.colorRed, renderingMode: .alwaysOriginal) ?? UIImage()
        static let listCellDeadlineIcon = UIImage(systemName: "calendar")?.withTintColor(.ColorAsset.labelTertiary, renderingMode: .alwaysOriginal) ?? UIImage()
        static let openDetailActionIcon = UIImage(systemName: "info.circle.fill")?.withTintColor(.ColorAsset.colorWhite, renderingMode: .alwaysOriginal) ?? UIImage()
        static let deleteActionIcon = UIImage(systemName: "trash.fill")?.withTintColor(.ColorAsset.colorWhite, renderingMode: .alwaysOriginal)
        static let completeActionIcon = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.ColorAsset.colorWhite, renderingMode: .alwaysOriginal) ?? UIImage()
        static let newTodoItemButtonIcon = UIImage(systemName: "plus.circle.fill")?.withTintColor(.ColorAsset.colorBlue, renderingMode: .alwaysOriginal) ?? UIImage()
    }
}
