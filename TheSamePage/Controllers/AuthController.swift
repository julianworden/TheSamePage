//
//  AuthController.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import Foundation

final class AuthController: ObservableObject {
    /// Fetched UID for logged in user.
    /// - Returns: The UID of the logged in user. This value will be "Unknown UID" if fetching the
    /// UID fails for any reason.
    static func getLoggedInUid() -> String {
        return Auth.auth().currentUser?.uid ?? "Unknown UID"
    }
    
    static func getLoggedInUserName() async throws -> String {
        let user = try await DatabaseService.shared.getLoggedInUser()
        return user.firstName + " " + user.lastName
    }
    
    static func logOut() throws {
        try Auth.auth().signOut()
    }
    
    static func userIsLoggedOut() -> Bool {
        return Auth.auth().currentUser == nil
    }
}
