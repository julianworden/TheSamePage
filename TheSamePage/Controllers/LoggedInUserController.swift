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
    @Published var loggedInUser: User?
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var emailAddress: String?
    @Published var profileImageUrl: String?
    @Published var bands = [Band]()
    
    @Published var errorMessageShowing = false
    @Published var errorMessageText = ""
    
    var uid: String?
    
    let db = Firestore.firestore()
    var userListener: ListenerRegistration?
    
    init() {
        Task {
            await getLoggedInUserInfo()
        }
    }
    
    func getLoggedInUserInfo() async {
        do {
            let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
            self.loggedInUser = loggedInUser
            self.profileImageUrl = loggedInUser.profileImageUrl
            self.firstName = loggedInUser.firstName
            self.lastName = loggedInUser.lastName
            self.emailAddress = loggedInUser.emailAddress
            self.uid = loggedInUser.id
            self.bands = try await DatabaseService.shared.getBands(withUid: loggedInUser.id)
        } catch {
            errorMessageText = error.localizedDescription
            errorMessageShowing = true
        }
    }
    
    func logOut() {
        self.loggedInUser = nil
        self.firstName = nil
        self.lastName = nil
        self.emailAddress = nil
        self.profileImageUrl = nil
        self.bands = []

        do {
            try AuthController.logOut()
        } catch {
            errorMessageText = error.localizedDescription
            errorMessageShowing = true
        }
    }
    
    func addUserListener() {
        userListener = db.collection(FbConstants.users).document(AuthController.getLoggedInUid()).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let updatedUser = try? snapshot?.data(as: User.self) {
                    // loggedInUser must also be updated because the loggedInUserProfile references it
                    self.loggedInUser = updatedUser
                    self.firstName = updatedUser.firstName
                    self.lastName = updatedUser.lastName
                    self.emailAddress = updatedUser.emailAddress
                    self.profileImageUrl = updatedUser.profileImageUrl
                }
            } else if error != nil {
                self.errorMessageText = "Something went wrong, please log in again. System error: \(error!.localizedDescription)"
                self.errorMessageShowing = true
            }
        }
    }
    
    // TODO: Add listener to user's bands
    
    func removeUserListener() {
        userListener?.remove()
    }
}
