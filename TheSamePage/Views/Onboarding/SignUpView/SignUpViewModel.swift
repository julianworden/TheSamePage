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
    enum SignUpViewModelError: Error {
        case firebaseAuthError(message: String)
        case firestoreError(message: String)
        case firebaseStorageError(message: String)
        case unexpectedNilValue(value: String)
    }
    
    @Published var username = ""
    @Published var emailAddress = ""
    @Published var profileImage: UIImage?
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber: String?
    @Published var userIsInABand = false
    
    @Published var imagePickerIsShowing = false
    @Published var profileCreationWasSuccessful = false
    @Published var signUpButtonIsDisabled = false
    @Published var userIsOnboarding = true
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                signUpButtonIsDisabled = true
            case .workCompleted:
                if userIsInABand {
                    // Segues to InABandView
                    profileCreationWasSuccessful = true
                } else {
                    userIsOnboarding = false
                }
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                signUpButtonIsDisabled = false
            default:
                print("Unknown viewState set in SignUpViewModel: \(viewState)")
            }
        }
    }
    
    var formIsComplete: Bool {
        return !firstName.isReallyEmpty &&
               !lastName.isReallyEmpty
    }
    
    func signUpButtonTapped() async {
        guard formIsComplete else {
            viewState = .error(message: "Incomplete form. Please enter your first and last name.")
            return
        }

        viewState = .performingWork
        
        do {
            try await registerUser()
            viewState = .workCompleted
        } catch {
            let error = AuthErrorCode(_nsError: error as NSError)
            
            switch error.code {
            case .invalidEmail, .missingEmail:
                viewState = .error(message: "Please enter a valid email address.")
            case .emailAlreadyInUse:
                viewState = .error(message: "An account with this email address already exists, please go back and sign in or reset your password, if necessary.")
            case .networkError:
                viewState = .error(message: "Login failed. \(ErrorMessageConstants.checkYourConnection). System error: \(error.localizedDescription)")
            case .weakPassword:
                viewState = .error(message: "Please enter a valid password, it must be 6 characters long or more.")
            default:
                viewState = .error(message: "An unknown error occurred, please try again. System error: \(error.localizedDescription)")
                print(error)
            }
        }
    }
    
    /// Creates and registers a user in Firebase Auth with the email address and password entered by the user.
    ///
    /// Once the user is created in Firebase Auth, a new user object is created and passed to the DatabaseService,
    /// which will add that new user object to the users collection in Firestore.
    /// - Parameter image: The profile image selected by the user.
    func registerUser() async throws {
        let result = try await Auth.auth().createUser(withEmail: emailAddress, password: password)
        let uid = result.user.uid
        let fcmToken = Messaging.messaging().fcmToken
        
        let newUser: User
        
        if let profileImage {
            let imageUrl = try await DatabaseService.shared.uploadImage(image: profileImage)
            newUser = User(
                id: uid,
                username: username,
                firstName: firstName,
                lastName: lastName,
                profileImageUrl: imageUrl,
                phoneNumber: phoneNumber,
                emailAddress: emailAddress,
                fcmToken: fcmToken
            )
        } else {
            newUser = User(
                id: uid,
                username: username,
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber,
                emailAddress: emailAddress,
                fcmToken: fcmToken
            )
        }
        
        try await DatabaseService.shared.createUserObject(user: newUser)
    }
}
