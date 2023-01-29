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
    @Published var bands = [Band]()
    
    /// The image loaded from the ProfileAsyncImage in LoggedInUserProfileView
    @Published var userImage: Image?
    /// A new image set within EditImageView
    @Published var updatedImage: UIImage?
    
    @Published var errorMessageShowing = false
    @Published var errorMessageText = ""

    @Published var currentUserIsInvalid = false
    @Published var currentUserHasNoUsernameAlertIsShowing = false
    @Published var createUsernameSheetIsShowing = false
    
    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .error(let message):
                errorMessageText = message
                errorMessageShowing = true
            default:
                print("Unknown viewState passed to LoggedInUserController: \(viewState)")
            }
        }
    }

    var userIsLoggedOut: Bool {
        AuthController.userIsLoggedOut()
    }

    let db = Firestore.firestore()

    func callOnAppLaunchMethods() async {
        guard !AuthController.userIsLoggedOut() else { return }

        await getLoggedInUserInfo()
        await getLoggedInUserBands()
    }

    func getLoggedInUserInfo() async {
        do {
            self.loggedInUser = try await DatabaseService.shared.getLoggedInUser()
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getLoggedInUserBands() async {
        guard let loggedInUser else { return }

        do {
            self.bands = try await DatabaseService.shared.getBands(withUid: loggedInUser.id)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func deleteProfileImage() async {
        guard let loggedInUser else { return }

        do {
            try await DatabaseService.shared.deleteUserProfileImage(forUser: loggedInUser)
            userImage = nil
            updatedImage = nil
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func removeUserFromBand(remove user: User, from band: Band) async {
        do {
            let userAsBandMember = try await DatabaseService.shared.convertUserToBandMember(user: user, band: band)
            try await DatabaseService.shared.removeUserFromBand(remove: user, as: userAsBandMember, from: band)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func logOut() {
        self.loggedInUser = nil
        self.userImage = nil
        self.updatedImage = nil
        self.bands = []

        do {
            try AuthController.logOut()
            currentUserIsInvalid = true
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func validateUserLogInStatusAndEmailVerification() async {
        guard !userIsLoggedOut,
              AuthController.loggedInUserEmailIsVerified() else {
            currentUserIsInvalid = true
            return
        }
    }

    func validateIfUserHasUsername() async {
        do {
            let currentUser = try await DatabaseService.shared.getLoggedInUser()
            if currentUser.username.isReallyEmpty {
                currentUserHasNoUsernameAlertIsShowing = true
            } else {
                currentUserHasNoUsernameAlertIsShowing = false
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
