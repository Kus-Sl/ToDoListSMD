//
//  Extension + UITableViewCell.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 05.08.2022.
//

import UIKit

extension UITableViewCell {
    class func cellReuseIdentifier() -> String {
        self.description()
    }
}
