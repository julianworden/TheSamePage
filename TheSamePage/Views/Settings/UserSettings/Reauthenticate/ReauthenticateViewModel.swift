//
//  ReauthenticateViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/29/23.
//

import FirebaseAuth
import Foundation

@MainActor
class ReauthenticateViewModel: ObservableObject {
    @Published var emailAddress = ""
    @Published var password = ""

    @Published var submitButtonIsDisabled = false
    @Published var reauthenticationSuccessful = false

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                submitButtonIsDisabled = true
            case .workCompleted:
                reauthenticationSuccessful = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                submitButtonIsDisabled = false
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }

    func reauthenticateUser() async {
        do {
            viewState = .performingWork
            let authCredential = EmailAuthProvider.credential(withEmail: emailAddress, password: password)
            try await Auth.auth().currentUser?.reauthenticate(with: authCredential)
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
}
