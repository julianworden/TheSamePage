//
//  AuthController.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import Foundation

class AuthController: ObservableObject {
    /// Fetched UID for logged in user.
    /// - Returns: The UID of the logged in user. This value will be "Unknown UID" if fetching the
    /// UID fails for any reason.
    static func getLoggedInUid() -> String {
        return Auth.auth().currentUser?.uid ?? "Unknown UID"
    }
}
