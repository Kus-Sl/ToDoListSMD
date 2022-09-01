//
//  Typealiases.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 23.08.2022.
//

import Foundation

typealias VoidResult = Result<(), Error>
typealias RevisionResult = Result<Int, Error>
typealias ListResult = Result<([TodoItem]), Error>
typealias TupleResult = Result<([TodoItem], Int), Error>
