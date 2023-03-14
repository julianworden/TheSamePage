//
//  ForgotPasswordViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/26/23.
//

import FirebaseAuth
import Foundation

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    @Published var emailAddress = ""

    @Published var buttonsAreDisabled = false

    @Published var successfullySentPasswordResetEmailAlertIsShowing = false
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    var successfullySentPasswordResetEmailAlertText = "A password reset email was successfully sent to your email address. You can use the instructions in that email to reset your password."

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                successfullySentPasswordResetEmailAlertIsShowing = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }

    func sendPasswordResetEmail() async {
        do {
            viewState = .performingWork
            let actionCodeSettings = ActionCodeSettings()
            // This line tells Firebase to direct the user to the url set in the
            // url property AFTER they've reset their password. If this is true, the link
            // in the password reset email will direct the user straight to the URL in the url property
            actionCodeSettings.handleCodeInApp = false
            if let appBundleId = Bundle.main.bundleIdentifier {
                actionCodeSettings.setIOSBundleID(appBundleId)
            }
            actionCodeSettings.url = URL(string: DynamicLinkConstants.accountModificationLandingPage)
            try await Auth.auth().sendPasswordReset(withEmail: emailAddress, actionCodeSettings: actionCodeSettings)
            viewState = .workCompleted
        } catch {
            let error = AuthErrorCode(_nsError: error as NSError)

            switch error.code {
            case .userNotFound:
                viewState = .error(message: ErrorMessageConstants.emailAddressDoesNotBelongToAccountOnForgotPassword)
            case .invalidEmail, .missingEmail:
                viewState = .error(message: ErrorMessageConstants.invalidEmailAddress)
            default:
                viewState = .error(message: "\(ErrorMessageConstants.unknownError). System error: \(error.localizedDescription)")
            }
        }
    }
}
