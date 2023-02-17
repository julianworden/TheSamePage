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
    @Published var playingBands = [Band]()
    @Published var adminBands = [Band]()
    @Published var hostedShows = [Show]()
    
    /// The image loaded from the ProfileAsyncImage in LoggedInUserProfileView
    @Published var userImage: Image?
    /// A new image set within EditImageView
    @Published var updatedImage: UIImage?
    
    @Published var errorMessageShowing = false
    @Published var errorMessageText = ""

    @Published var currentUserIsInvalid = false
    @Published var currentUserHasNoUsernameAlertIsShowing = false
    @Published var createUsernameSheetIsShowing = false
    @Published var accountDeletionWasSuccessful = false
    @Published var passwordChangeWasSuccessful = false
    @Published var usernameChangeWasSuccessful = false
    @Published var emailAddressChangeWasSuccessful = false
    
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
        return AuthController.userIsLoggedOut()
    }

    var loggedInUserIsNotLeadingAnyShowsOrBands: Bool {
        return adminBands.isEmpty && hostedShows.isEmpty
    }

    var upcomingHostedShows: [Show] {
        return hostedShows.filter { !$0.alreadyHappened }
    }

    let db = Firestore.firestore()

    func callOnAppLaunchMethods() async {
        guard !AuthController.userIsLoggedOut() else { return }

        await getLoggedInUserInfo()
        await getLoggedInUserPlayingBands()
    }

    func getLoggedInUserInfo() async {
        do {
            self.loggedInUser = try await DatabaseService.shared.getLoggedInUser()
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getLoggedInUserPlayingBands() async {
        guard let loggedInUser else { return }

        do {
            self.playingBands = try await DatabaseService.shared.getJoinedBands(withUid: loggedInUser.id)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getLoggedInUserAdminBands() async {
        guard let loggedInUser else { return }

        do {
            self.adminBands = try await DatabaseService.shared.getAdminBands(withUid: loggedInUser.id)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getLoggedInUserHostedShows() async {
        guard loggedInUser != nil else { return }

        do {
            self.hostedShows = try await DatabaseService.shared.getLoggedInUserHostedShows()
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
    
    func logOut() async {
        self.loggedInUser = nil
        self.userImage = nil
        self.updatedImage = nil
        self.playingBands = []

        do {
            try await DatabaseService.shared.deleteFcmTokenForUser(withUid: AuthController.getLoggedInUid())
            try AuthController.logOut()
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

    func deleteAccount() async {
        do {
            try await DatabaseService.shared.deleteAccountInFirebaseAuthAndFirestore(forUserWithUid: AuthController.getLoggedInUid())
            accountDeletionWasSuccessful = true
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func changePassword(to password: String) async {
        do {
            try await AuthController.changePassword(to: password)
            passwordChangeWasSuccessful = true
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func usernameIsValid(_ username: String) async throws -> Bool {
        guard username.count >= 3 else {
            viewState = .error(message: ErrorMessageConstants.usernameIsTooShort)
            return false
        }

        guard try await DatabaseService.shared.newUsernameIsNotAlreadyTaken(username.lowercasedAndTrimmed) else {
            viewState = .error(message: ErrorMessageConstants.usernameIsAlreadyTaken)
            return false
        }

        return true
    }

    func changeUsername(to username: String) async {
        do {
            guard try await usernameIsValid(username) else {
                return
            }

            try await DatabaseService.shared.createOrUpdateUsername(username.lowercasedAndTrimmed)
            usernameChangeWasSuccessful = true
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func changeEmailAddress(to emailAddress: String) async {
        do {
            try await DatabaseService.shared.changeEmailAddress(to: emailAddress)
            try await sendEmailVerificationEmailToCurrentUser()
            emailAddressChangeWasSuccessful = true
        } catch {
            let error = AuthErrorCode(_nsError: error as NSError)

            switch error.code {
            case .invalidEmail, .missingEmail:
                viewState = .error(message: ErrorMessageConstants.invalidOrMissingEmailOnSignUp)
            case .emailAlreadyInUse:
                viewState = .error(message: ErrorMessageConstants.emailAlreadyInUseOnSignUp)
            case .networkError:
                viewState = .error(message: "\(ErrorMessageConstants.networkErrorOnSignUp). System error: \(error.localizedDescription)")
            default:
                viewState = .error(message: "\(ErrorMessageConstants.unknownError). System error: \(error.localizedDescription)")
            }
        }
    }

    func sendEmailVerificationEmailToCurrentUser() async throws {
        let actionCodeSettings = ActionCodeSettings()
        // This line tells Firebase to direct the user to the url set in the
        // url property AFTER they've reset their password. If this is true, the link
        // in the password reset email will direct the user straight to the URL in the url property
        actionCodeSettings.handleCodeInApp = false
        if let appBundleId = Bundle.main.bundleIdentifier {
            actionCodeSettings.setIOSBundleID(appBundleId)
        }
        actionCodeSettings.url = URL(string: "https://thesamepage.page.link")

        try await Auth.auth().currentUser?.sendEmailVerification(with: actionCodeSettings)
    }
}
