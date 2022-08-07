//
//  BaseCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 30.07.2022.
//

import UIKit

class BaseCell: UITableViewCell {
    lazy var content = defaultContentConfiguration()

    var viewModel: DetailViewModelProtocol! {
        didSet {
            setupContent()
            setupControl()
        }
    }

    func setupContent() {
        backgroundColor = UIColor.colorAsset.backSecondary
        content.textProperties.color = UIColor.colorAsset.labelPrimary!
        content.textProperties.font = UIFont.FontAsset.body
    }

    func setupControl() {}
}
