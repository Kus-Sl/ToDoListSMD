//
//  TodoItem.swift
//  TodoListSMD
//
//  Created by Вячеслав Кусакин on 26.07.2022.
//

import Foundation
struct TodoItem {
    var id: String
    let text: String

    let importance: Importance
    let isDone: Bool

    let creationDate: Date
    let changeDate: Date?
    let deadLine: Date?

    enum Importance: String {
        case important = "важная"
        case ordinary = "обычная"
        case unimportant = "неважная"
    }
}

// MARK: JSON Conversion
extension TodoItem {
    var json: Any {
        var jsonDict: [String: Any] = [
            "id" : id,
            "text" : text,
            "isDone" : isDone,
            "creationDate" : creationDate.timeIntervalSince1970
        ]

        if importance != .ordinary {
            jsonDict["importance"] = importance
        }

        if let deadLine = deadLine {
            jsonDict["deadLine"] = deadLine.timeIntervalSince1970
        }

        if let changeDate = changeDate {
            jsonDict["changeDate"] = changeDate.timeIntervalSince1970
        }

        return jsonDict
    }

    static func parse(json: Any) -> TodoItem? {
        guard let jsonDict = json as? [String: Any] else { return nil }

        return TodoItem(
            id: jsonDict["id"] as? String ?? "",
            text: jsonDict["text"] as? String ?? "",
            importance: jsonDict["importance"] as? Importance ?? .ordinary,
            isDone: jsonDict["isDone"] as? Bool ?? false,
            creationDate: getDate(from: jsonDict["creationDate"] as Any) ?? Date(),
            changeDate: getDate(from: jsonDict["changeDate"] as Any),
            deadLine: getDate(from: jsonDict["deadLine"] as Any)
        )
    }
}

// MARK: Date formatting
extension TodoItem {
    private static func getDate(from json: Any) -> Date? {
        guard let unixTime = json as? TimeInterval else { return nil }
        let date = Date(timeIntervalSince1970: unixTime)
        return date
    }
}
