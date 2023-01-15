//
//  LoginViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var emailAddress = ""
    @Published var password = ""
    
    @Published var loginErrorShowing = false
    @Published var loginErrorMessage = ""
    @Published var loginButtonIsDisabled = false
    @Published var userIsOnboarding = true
    
    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .error(let message):
                loginErrorMessage = message
                loginErrorShowing = true
                loginButtonIsDisabled = false
            case .performingWork:
                loginButtonIsDisabled = true
            case .workCompleted:
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
            try await Auth.auth().signIn(withEmail: emailAddress, password: password)
            viewState = .workCompleted
        } catch {
            let error = AuthErrorCode(_nsError: error as NSError)
            
            switch error.code {
            case .invalidEmail:
                viewState = .error(message: ErrorMessageConstants.invalidEmailAddressOnSignIn)
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
