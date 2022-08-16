//
//  TodoItem.swift
//  TodoListSMD
//
//  Created by Вячеслав Кусакин on 26.07.2022.
//

import Foundation
import CocoaLumberjack

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let isDone: Bool
    let creationDate: Int
    let changeDate: Int?
    let deadline: Int?

    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance = .ordinary,
        isDone: Bool = false,
        creationDate: Int = Int(Date().timeIntervalSince1970),
        changeDate: Int? = nil,
        deadline: Int? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.isDone = isDone
        self.creationDate = creationDate
        self.changeDate = changeDate
        self.deadline = deadline
    }
}

// MARK: JSON Conversion
extension TodoItem {
    var json: Any {
        var jsonDict: [String: Any] = [
            Keys.idKey: id,
            Keys.textKey: text,
            Keys.isDoneKey: isDone,
            Keys.creationDateKey: creationDate
        ]

        if importance != .ordinary {
            jsonDict[Keys.importanceKey] = importance.rawValue
        }

        if let deadline = deadline {
            jsonDict[Keys.deadlineKey] = deadline
        }

        if let changeDate = changeDate {
            jsonDict[Keys.changeDateKey] = changeDate
        }

        return jsonDict
    }

    static func parse(json: Any) -> TodoItem? {
        guard let jsonDict = json as? [String: Any] else { return nil }

        return TodoItem(
            id: jsonDict[Keys.idKey] as? String ?? "",
            text: jsonDict[Keys.textKey] as? String ?? "",
            importance: .init(rawValue: jsonDict[Keys.importanceKey] as? String ?? "") ?? .ordinary,
            isDone: jsonDict[Keys.isDoneKey] as? Bool ?? false,
            creationDate: jsonDict[Keys.creationDateKey] as? Int ?? Int(Date().timeIntervalSince1970),
            changeDate: jsonDict[Keys.changeDateKey] as? Int,
            deadline: jsonDict[Keys.deadlineKey] as? Int
        )
    }
}

extension TodoItem {
    var asCompleted: TodoItem {
        TodoItem(
            id: id,
            text: text,
            importance: importance,
            isDone: true,
            creationDate: creationDate,
            changeDate: Int(Date().timeIntervalSince1970),
            deadline: deadline
        )
    }

    // NB: реализовать обратный функционал
}

// MARK: Constants
extension TodoItem {
    private enum Keys {
        static let idKey = "id"
        static let textKey = "text"
        static let importanceKey = "importance"
        static let isDoneKey = "isDone"
        static let creationDateKey = "creationDate"
        static let changeDateKey = "changeDate"
        static let deadlineKey = "deadline"
    }
}

enum Importance: String {
    case important = "важная"
    case ordinary = "обычная"
    case unimportant = "неважная"
}
