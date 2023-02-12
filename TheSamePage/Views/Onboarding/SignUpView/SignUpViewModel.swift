//
//  SignUpViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging
import Foundation
import UIKit.UIImage

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var emailAddress = ""
    @Published var confirmedEmailAddress = ""
    @Published var profileImage: UIImage?
    @Published var password = ""
    @Published var confirmedPassword = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber: String?

    @Published var imagePickerIsShowing = false
    @Published var profileCreationWasSuccessful = false
    @Published var signUpButtonIsDisabled = false
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                signUpButtonIsDisabled = true
            case .workCompleted:
                profileCreationWasSuccessful = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                signUpButtonIsDisabled = false
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }

    var emailAddressesMatch: Bool {
        return emailAddress.lowercasedAndTrimmed == confirmedEmailAddress.lowercasedAndTrimmed
    }

    var passwordsMatch: Bool {
        return password.trimmed == confirmedPassword.trimmed
    }
    
    var firstAndLastNameAreFilled: Bool {
        return !firstName.isReallyEmpty &&
               !lastName.isReallyEmpty
    }
    
    @discardableResult func signUpButtonTapped() async -> String {
        do {
            guard emailAddressesMatch else {
                viewState = .error(message: ErrorMessageConstants.emailAddressesDoNotMatch)
                return ""
            }

            guard passwordsMatch else {
                viewState = .error(message: ErrorMessageConstants.passwordsDoNotMatch)
                return ""
            }

            guard firstAndLastNameAreFilled else {
                viewState = .error(message: ErrorMessageConstants.missingFirstAndLastNameOnSignUp)
                return ""
            }

            viewState = .performingWork
            let newUserUid = try await registerUser()
            viewState = .workCompleted
            return newUserUid
        } catch {
            let error = AuthErrorCode(_nsError: error as NSError)
            
            switch error.code {
            case .invalidEmail, .missingEmail:
                viewState = .error(message: ErrorMessageConstants.invalidOrMissingEmailOnSignUp)
            case .emailAlreadyInUse:
                viewState = .error(message: ErrorMessageConstants.emailAlreadyInUseOnSignUp)
            case .networkError:
                viewState = .error(message: "\(ErrorMessageConstants.networkErrorOnSignUp). System error: \(error.localizedDescription)")
            case .weakPassword:
                viewState = .error(message: ErrorMessageConstants.weakPasswordOnSignUp)
            default:
                viewState = .error(message: "\(ErrorMessageConstants.unknownError). System error: \(error.localizedDescription)")
            }

            return ""
        }
    }
    
    /// Creates and registers a user in Firebase Auth with the email address and password entered by the user.
    ///
    /// Once the user is created in Firebase Auth, a new user object is created and passed to the DatabaseService,
    /// which will add that new user object to the users collection in Firestore.
    /// - Parameter image: The profile image selected by the user.
    func registerUser() async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: emailAddress.lowercasedAndTrimmed, password: password)
        let uid = result.user.uid
        let fcmToken = Messaging.messaging().fcmToken
        
        let newUser: User
        
        newUser = User(
            id: uid,
            username: "",
            firstName: firstName,
            lastName: lastName,
            profileImageUrl: profileImage == nil ? nil : try await DatabaseService.shared.uploadImage(image: profileImage!),
            phoneNumber: phoneNumber,
            emailAddress: emailAddress.lowercasedAndTrimmed,
            fcmToken: fcmToken
        )
        
        try await DatabaseService.shared.createUserObject(user: newUser)
        try await sendEmailVerificationEmail(to: result.user)

        return uid
    }

    func sendEmailVerificationEmail(to user: FirebaseAuth.User) async throws {
        let actionCodeSettings = ActionCodeSettings()
        // This line tells Firebase to direct the user to the url set in the
        // url property AFTER they've reset their password. If this is true, the link
        // in the password reset email will direct the user straight to the URL in the url property
        actionCodeSettings.handleCodeInApp = false
        if let appBundleId = Bundle.main.bundleIdentifier {
            actionCodeSettings.setIOSBundleID(appBundleId)
        }
        actionCodeSettings.url = URL(string: "https://thesamepage.page.link")
        
        try await user.sendEmailVerification(with: actionCodeSettings)
    }
}
