//
//  UserViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import UIKit.UIImage

@MainActor
class LoggedInUserController: ObservableObject {
    @Published var loggedInUser: User?
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var emailAddress: String?
    @Published var profileImageUrl: String?
    @Published var bands = [Band]()
    
    /// The image loaded from the ProfileAsyncImage
    @Published var userImage: Image?
    /// A new image set within EditImageView
    @Published var updatedImage: UIImage?
    
    @Published var errorMessageShowing = false
    @Published var errorMessageText = ""
    
    @Published var loggedInUserProfileViewState = ViewState.displayingView {
        didSet {
            switch loggedInUserProfileViewState {
            case .error(let message):
                errorMessageText = message
                errorMessageShowing = true
            default:
                print("Unknown viewState passed to LoggedInUserController: \(loggedInUserProfileViewState)")
            }
        }
    }
    
    var uid: String?
    
    let db = Firestore.firestore()
    var userListener: ListenerRegistration?
    
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
            loggedInUserProfileViewState = .error(message: error.localizedDescription)
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
            loggedInUserProfileViewState = .error(message: error.localizedDescription)
        }
    }
    
    func addUserListener() {
        userListener = db.collection(FbConstants.users).document(AuthController.getLoggedInUid()).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                do {
                    if let updatedUser = try? snapshot?.data(as: User.self) {
                        // loggedInUser must also be updated because the loggedInUserProfile references it
                        self.loggedInUser = updatedUser
                        self.firstName = updatedUser.firstName
                        self.lastName = updatedUser.lastName
                        self.emailAddress = updatedUser.emailAddress
                        self.profileImageUrl = updatedUser.profileImageUrl
                    } else {
                        self.loggedInUserProfileViewState = .error(message: "Failed to fetch updated user info. Please relaunch The Same Page and try again.")
                    }
                }
            } else if error != nil {
                self.loggedInUserProfileViewState = .error(message: error!.localizedDescription)
            }
        }
    }
    
    // TODO: Add listener to user's bands
    
    func removeUserListener() {
        userListener?.remove()
    }
}
