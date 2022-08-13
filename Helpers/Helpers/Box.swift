//
//  Box.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 06.08.2022.
//

import Foundation

public class Box<T> {
    public typealias Listener = (T) -> ()

    public var listener: Listener?
    public var value: T {
        didSet {
            listener?(value)
        }
    }

    public init(value: T) {
        self.value = value
    }

    public func bind(listener: @escaping Listener) {
        self.listener = listener
        listener(value)
    }
}
