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
        static let importantSegmentedControlIcon = UIImage(systemName: "exclamationmark.2")?.withTintColor(.colorAsset.colorRed!, renderingMode: .alwaysOriginal)
        static let unimportantSegmentedControlIcon = UIImage(systemName: "arrow.down")?.withTintColor(.colorAsset.colorGray!, renderingMode: .alwaysOriginal)
        static let listCellDirectionIcon = UIImage(systemName: "chevron.forward")?.withTintColor(.colorAsset.colorGray!, renderingMode: .alwaysOriginal)
        static let listCellCheckmarkIcon = UIImage(systemName: "circle")?.withTintColor(.colorAsset.supportSeparator!, renderingMode: .alwaysOriginal)
        static let listCellCheckmarkDoneIcon = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.colorAsset.colorGreen!, renderingMode: .alwaysOriginal)
        static let listCellCheckmarkExpiredIcon = UIImage(systemName: "circle")?.withTintColor(.colorAsset.colorRed!, renderingMode: .alwaysOriginal)
        static let listCellDeadlineIcon = UIImage(systemName: "calendar")?.withTintColor(.colorAsset.labelTertiary!, renderingMode: .alwaysOriginal)
        static let openDetailActionIcon = UIImage(systemName: "info.circle.fill")?.withTintColor(.colorAsset.colorWhite!, renderingMode: .alwaysOriginal)
        static let deleteActionIcon = UIImage(systemName: "trash.fill")?.withTintColor(.colorAsset.colorWhite!, renderingMode: .alwaysOriginal)
        static let completeActionIcon = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.colorAsset.colorWhite!, renderingMode: .alwaysOriginal)
    }
}
