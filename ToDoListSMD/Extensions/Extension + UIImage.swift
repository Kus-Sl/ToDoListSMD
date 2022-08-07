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
        static let importantSegmentedControlImage = UIImage(systemName: "exclamationmark.2")?.withTintColor(.colorAsset.colorRed!, renderingMode: .alwaysOriginal)
        static let unimportantSegmentedControlImage = UIImage(systemName: "arrow.down")?.withTintColor(.colorAsset.colorGray!, renderingMode: .alwaysOriginal)
        static let listCellDirectionArrow = UIImage(systemName: "chevron.forward")?.withTintColor(.colorAsset.colorGray!, renderingMode: .alwaysOriginal)
        static let listCellCheckmark = UIImage(systemName: "circle")?.withTintColor(.colorAsset.supportSeparator!, renderingMode: .alwaysOriginal)
        static let listCellCheckmarkDone = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.colorAsset.colorGreen!, renderingMode: .alwaysOriginal)
        static let listCellCheckmarkExpired = UIImage(systemName: "circle")?.withTintColor(.colorAsset.colorRed!, renderingMode: .alwaysOriginal)
        static let listCellDeadlineCalendar = UIImage(systemName: "calendar")?.withTintColor(.colorAsset.labelTertiary!, renderingMode: .alwaysOriginal)
    }
}
