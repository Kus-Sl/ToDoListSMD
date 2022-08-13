//
//  BaseCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 30.07.2022.
//

import UIKit
import CocoaLumberjack

class BaseCell: UITableViewCell {
    lazy var content = defaultContentConfiguration()

    var viewModel: DetailViewModelProtocol! {
        didSet {
            setupContent()
            setupControl()
        }
    }

    func setupContent() {
        backgroundColor = .ColorAsset.backSecondary
        content.textProperties.color = .ColorAsset.labelPrimary
        content.textProperties.font = .FontAsset.body
    }

    func setupControl() {}
}
