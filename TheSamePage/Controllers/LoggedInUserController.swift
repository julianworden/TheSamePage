//
//  UserViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
class LoggedInUserController: ObservableObject {
    enum UserControllerError: Error {
        case firebaseAuth(message: String)
        case firestore(message: String)
    }
    
    @Published var loggedInUser: User?
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var emailAddress: String?
    @Published var profileImageUrl: String?
    @Published var bands = [Band]()
    
    var uid: String?
    
    let db = Firestore.firestore()
    var userListener: ListenerRegistration?
    
    init() {
        Task {
            do {
                try await getLoggedInUserInfo()
            } catch {
                throw UserControllerError.firestore(message: "Failed to fetch logged in user")
            }
        }
    }
    
    func getLoggedInUserInfo() async throws {
        guard !AuthController.userIsLoggedOut() else {
            throw UserControllerError.firebaseAuth(message: "No logged in user found in UserController.getLoggedInUser")
        }
        
        let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
        self.loggedInUser = loggedInUser
        self.profileImageUrl = loggedInUser.profileImageUrl
        self.firstName = loggedInUser.firstName
        self.lastName = loggedInUser.lastName
        self.emailAddress = loggedInUser.emailAddress
        self.uid = loggedInUser.id
        self.bands = try await DatabaseService.shared.getBands(withUid: loggedInUser.id)
    }
    
    func logOut() throws {
        guard !AuthController.userIsLoggedOut() else {
            throw UserControllerError.firebaseAuth(message: "User is already logged out. Thrown in LoggedInUserController.logOut()")
        }
        
        self.loggedInUser = nil
        self.firstName = nil
        self.lastName = nil
        self.emailAddress = nil
        self.profileImageUrl = nil
        self.bands = []

        do {
            try AuthController.logOut()
        } catch {
            throw UserControllerError.firebaseAuth(message: "Failed to log out")
        }
    }
    
    func addUserListener() {
        userListener = db.collection("users").document(AuthController.getLoggedInUid()).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let updatedUser = try? snapshot?.data(as: User.self) {
                    // loggedInUser must also be updated because the loggedInUserProfile references it
                    self.loggedInUser = updatedUser
                    self.firstName = updatedUser.firstName
                    self.lastName = updatedUser.lastName
                    self.emailAddress = updatedUser.emailAddress
                    self.profileImageUrl = updatedUser.profileImageUrl
                }
            }
        }
    }
    
    // TODO: Add listener to user's bands
    
    func removeUserListener() {
        userListener?.remove()
    }
}
