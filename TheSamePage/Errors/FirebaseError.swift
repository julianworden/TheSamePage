//
//  FirebaseError.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/20/22.
//

import Foundation

enum FirebaseError: Error, LocalizedError {
    case auth(message: String, systemError: String)
    case userNotFound(message: String)
    case connection(message: String, systemError: String)
    case dataDeleted
    
    var errorDescription: String? {
        switch self {
        case .auth(let message, let systemError), .connection(let message, let systemError):
            return "\(message). \(ErrorMessageConstants.checkYourConnection). System error: \(systemError)"
        case .userNotFound(let message):
            return "\(message)."
        case .dataDeleted:
            return "The data could not be displayed because it was deleted."
        }
    }
}
