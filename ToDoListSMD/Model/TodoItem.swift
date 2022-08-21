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
    let importance: String
    let isDone: Bool
    let creationDate: Int
    let changeDate: Int?
    let deadline: Int?
    let isDirty: Bool

    init(
        id: String = UUID().uuidString,
        text: String,
        importance: String = Importance.ordinary.rawValue,
        isDone: Bool = false,
        creationDate: Int = Int(Date().timeIntervalSince1970),
        changeDate: Int? = nil,
        deadline: Int? = nil,
        isDirty: Bool = false
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.isDone = isDone
        self.creationDate = creationDate
        self.changeDate = changeDate
        self.deadline = deadline
        self.isDirty = isDirty
    }

    init(_ todoItemNetwork: TodoItemNetwork) {
        id = todoItemNetwork.id
        text = todoItemNetwork.text
        importance = todoItemNetwork.importance
        isDone = todoItemNetwork.isDone
        creationDate = todoItemNetwork.creationDate
        changeDate = todoItemNetwork.changeDate
        deadline = todoItemNetwork.deadline
        isDirty = false
    }
}

// MARK: JSON Conversion
extension TodoItem {
    var json: Any {
        var jsonDict: [String: Any] = [
            Keys.idKey: id,
            Keys.textKey: text,
            Keys.isDoneKey: isDone,
            Keys.creationDateKey: creationDate,
            Keys.isDirtyKey: isDirty
        ]

        if importance != Importance.ordinary.rawValue {
            jsonDict[Keys.importanceKey] = importance
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
            importance: jsonDict[Keys.importanceKey] as? String ?? Importance.ordinary.rawValue,
            isDone: jsonDict[Keys.isDoneKey] as? Bool ?? false,
            creationDate: jsonDict[Keys.creationDateKey] as? Int ?? Int(Date().timeIntervalSince1970),
            changeDate: jsonDict[Keys.changeDateKey] as? Int,
            deadline: jsonDict[Keys.deadlineKey] as? Int,
            isDirty: jsonDict[Keys.isDirtyKey] as? Bool ?? false
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
            deadline: deadline,
            isDirty: isDirty
        )
    }

    // NB: реализовать обратный функционал

    var asDirty: TodoItem {
        TodoItem(
            id: id,
            text: text,
            importance: importance,
            isDone: isDone,
            creationDate: creationDate,
            changeDate: changeDate,
            deadline: deadline,
            isDirty: true
        )
    }
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
        static let isDirtyKey = "IsDirty"
    }
}

enum Importance: String {
    case important = "important"
    case ordinary = "basic"
    case unimportant = "low"
}
