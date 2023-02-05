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
    
    static func getLoggedInUsername() async throws -> String {
        let user = try await DatabaseService.shared.getLoggedInUser()
        return user.username
    }

    static func getLoggedInUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    static func getLoggedInFullName() async throws -> String {
        let user = try await DatabaseService.shared.getLoggedInUser()
        return "\(user.firstName) \(user.lastName)"
    }

    static func loggedInUserEmailIsVerified() -> Bool {
        guard let currentUser = Auth.auth().currentUser else { return false }

        return currentUser.isEmailVerified
    }
    
    static func getLoggedInFcmToken() async throws -> String {
        let user = try await DatabaseService.shared.getLoggedInUser()
        return user.fcmToken ?? "Unknown FCM Token"
    }
    
    static func logOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw FirebaseError.auth(
                message: "Failed to log out",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Detects whether or not Firebase Auth's currentUser object is nil.
    ///
    /// This method will falsely detect that the currentUser property is not nil
    /// if a user's profile was deleted since the last time they opened the app.
    /// - Returns: Whether or not there is a logged in user.
    static func userIsLoggedOut() -> Bool {
        return Auth.auth().currentUser == nil
    }

    static func changePassword(to password: String) async throws {
        try await Auth.auth().currentUser?.updatePassword(to: password)
    }
}
