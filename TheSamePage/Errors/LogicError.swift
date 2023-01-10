//
//  LogicError.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/20/22.
//

import Foundation

enum LogicError: Error, LocalizedError {
    case decode(message: String, systemError: String? = nil)
    case unexpectedNilValue(message: String, systemError: String? = nil)
    case incompleteForm
    case emptyChatMessage
    
    var errorDescription: String? {
        switch self {
        case .decode(let message, let systemError), .unexpectedNilValue(let message, let systemError):
            if let systemError {
                return "\(message). System error: \(systemError)"
            } else {
                return "\(message)."
            }
        case .incompleteForm:
            return ErrorMessageConstants.incompleteForm
        case .emptyChatMessage:
            return ErrorMessageConstants.emptyChatMessage
        }
    }
}
