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
            default:
                print("Unknown viewState assigned to LoginViewModel")
            }
        }
    }
    
    func userIsOnboardingAfterLoginWith(emailAddress: String, password: String) async {
        do {
            loginButtonIsDisabled = true
            try await Auth.auth().signIn(withEmail: emailAddress, password: password)
            userIsOnboarding = false
        } catch {
            let error = AuthErrorCode(_nsError: error as NSError)
            
            switch error.code {
            case .invalidEmail:
                viewState = .error(message: "Please enter a valid email address")
            case .networkError:
                viewState = .error(message: "Login failed. \(ErrorMessageConstants.checkYourConnection). System error: \(error.localizedDescription)")
            case .wrongPassword:
                viewState = .error(message: "Incorrect email or password. Please try again.")
            default:
                viewState = .error(message: "An unknown error occurred, please try again. System error: \(error.localizedDescription)")
            }
            
        }
    }
}
