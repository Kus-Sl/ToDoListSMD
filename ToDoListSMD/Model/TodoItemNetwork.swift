//
//  TodoItemNetwork.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 16.08.2022.
//

import Foundation

struct Response: Codable {
    let element: TodoItemNetwork?
    let list: [TodoItemNetwork]?
    let revision: Int?
}

struct TodoItemNetwork: Codable {
    let id: String
    let text: String
    let importance: String
    let isDone: Bool
    let creationDate: Int
    let changeDate: Int
    let deadline: Int?
    let lastUpdatedBy: String

    init(_ todoItem: TodoItem) {
        id = todoItem.id
        text = todoItem.text
        importance = todoItem.importance
        isDone = todoItem.isDone
        creationDate = todoItem.creationDate
        changeDate = todoItem.changeDate ?? todoItem.creationDate
        deadline = todoItem.deadline
        lastUpdatedBy = "zdes id"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case isDone = "done"
        case creationDate = "created_at"
        case changeDate = "changed_at"
        case deadline
        case lastUpdatedBy = "last_updated_by"
    }
}
