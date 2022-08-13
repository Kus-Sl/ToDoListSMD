//
//  File.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 13.08.2022.
//

import Foundation
class LogFormatter {
    func format(message logMessage: DDLogMessage) -> String? {
        var logLevel = ""
        switch logMessage.flag {
        case DDLogFlag.debug: logLevel = "[Debug] -> "
        case DDLogFlag.info: logLevel = "[Info] -> "
        case DDLogFlag.warning: logLevel = "[Warning] -> "
        case DDLogFlag.error: logLevel = "[Error] -> "
        default: logLevel = "[Verbose] -> "
        }

        let formatterString = logLevel + logMessage.fileName + " -> " + logMessage.function + " -> " + "\(logMessage.line)" + " -> " + logMessage.message

        return formatterString
    }
}
