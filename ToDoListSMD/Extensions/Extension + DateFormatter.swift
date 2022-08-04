//
//  Extension + DateFormatter.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 31.07.2022.
//

import Foundation

extension DateFormatter {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "RU")
        formatter.timeZone = .current
        return formatter
    }()
}
