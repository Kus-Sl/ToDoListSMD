//
//  TodoItemCD+CoreDataProperties.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 28.08.2022.
//
//

import Foundation
import CoreData

extension TodoItemCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItemCD> {
        return NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")
    }

    @NSManaged public var changeDate: Int64
    @NSManaged public var creationDate: Int64
    @NSManaged public var deadLine: Int64
    @NSManaged public var id: String
    @NSManaged public var importance: String
    @NSManaged public var isDirty: Bool
    @NSManaged public var isDone: Bool
    @NSManaged public var text: String

}

extension TodoItemCD : Identifiable {

}
