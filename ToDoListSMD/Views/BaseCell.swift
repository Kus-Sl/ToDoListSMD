//
//  BaseCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 30.07.2022.
//

import UIKit

class BaseCell: UITableViewCell {
    var content: UIListContentConfiguration!

    var viewModel: DetailViewModelProtocol! {
        didSet {
            setupContent()
            setupControl()
        }
    }

    func setupContent() {
        backgroundColor = UIColor.colorAssets.backSecondary
        content = defaultContentConfiguration()
        content.textProperties.color = UIColor.colorAssets.labelPrimary!
        content.textProperties.font = UIFont.title
    }

    func setupControl() {}
}
