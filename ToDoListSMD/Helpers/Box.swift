//
//  Box.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 06.08.2022.
//

import Foundation

class Box<T> {
    typealias Listener = (T) -> ()

    var listener: Listener?
    var value: T {
        didSet {
            listener?(value)
        }
    }

    init(value: T) {
        self.value = value
    }

    func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(value)
    }
}
