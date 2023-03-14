//
//  LoginViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import FirebaseMessaging
import FirebaseFirestore
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var emailAddress = ""
    @Published var password = ""

    @Published var unverifiedEmailErrorShowing = false
    @Published var unverifiedEmailErrorText = ErrorMessageConstants.unverifiedEmailAddressOnSignIn
    @Published var createUsernameSheetIsShowing = false
    @Published var currentUserHasNoUsernameAlertIsShowing = false
    @Published var loginErrorShowing = false
    @Published var loginErrorMessage = ""
    @Published var buttonsAreDisabled = false
    @Published var userIsOnboarding = true
    
    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .error(let message):
                loginErrorMessage = message
                loginErrorShowing = true
                buttonsAreDisabled = false
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                currentUserHasNoUsernameAlertIsShowing = false
                userIsOnboarding = false
            default:
                loginErrorMessage = ErrorMessageConstants.invalidViewState
                loginErrorShowing = true
            }
        }
    }
    
    func logInUserWith(emailAddress: String, password: String) async {
        do {
            viewState = .performingWork
            let result = try await Auth.auth().signIn(withEmail: emailAddress, password: password)

            guard await signInAttemptIsValid(result: result) else { return }

            if !EnvironmentVariableConstants.unitTestsAreRunning,
               let deviceFcmToken = Messaging.messaging().fcmToken {
                try await DatabaseService.shared.updateFcmToken(to: deviceFcmToken, forUserWithUid: result.user.uid)
            }

            viewState = .workCompleted
        } catch {
            let error = AuthErrorCode(_nsError: error as NSError)
            
            switch error.code {
            case .invalidEmail:
                viewState = .error(message: ErrorMessageConstants.invalidEmailAddress)
            case .networkError:
                viewState = .error(message: "\(ErrorMessageConstants.networkErrorOnSignIn). System error: \(error.localizedDescription)")
            case .wrongPassword:
                viewState = .error(message: ErrorMessageConstants.wrongPasswordOnSignIn)
            case .userNotFound:
                // Password and email are valid, but no registered user has this info
                viewState = .error(message: ErrorMessageConstants.userNotFoundOnSignIn)
            default:
                viewState = .error(message: "\(ErrorMessageConstants.unknownError). System error: \(error.localizedDescription)")
            }
        }
    }

    func signInAttemptIsValid(result: AuthDataResult) async -> Bool {
        if !result.user.isEmailVerified {
            unverifiedEmailErrorShowing = true
            logOutUser()
            return false
        }

        if await !userHasUsername() {
            currentUserHasNoUsernameAlertIsShowing = true
            return false
        }

        return true
    }

    func logOutUser() {
        do {
            try AuthController.logOut()
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func sendEmailVerificationEmail() async {
        do {
            let actionCodeSettings = ActionCodeSettings()
            // This line tells Firebase to direct the user to the url set in the
            // url property AFTER they've reset their password. If this is true, the link
            // in the password reset email will direct the user straight to the URL in the url property
            actionCodeSettings.handleCodeInApp = false
            if let appBundleId = Bundle.main.bundleIdentifier {
                actionCodeSettings.setIOSBundleID(appBundleId)
            }
            actionCodeSettings.url = URL(string: DynamicLinkConstants.accountModificationLandingPage)

            try await Auth.auth().currentUser?.sendEmailVerification(with: actionCodeSettings)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func userHasUsername() async -> Bool {
        do {
            let currentUser = try await DatabaseService.shared.getLoggedInUser()
            if currentUser.name.isReallyEmpty {
                return false
            } else {
                return true
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
            return false
        }
    }
}
