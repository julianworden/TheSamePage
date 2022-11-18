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
    enum LoginViewModelError: Error {
        case authError(message: String)
    }
    
    @Published var emailAddress = ""
    @Published var password = ""
    
    @Published var loginErrorShowing = false
    @Published var loginErrorMessage = ""
    @Published var loginButtonIsDisabled = false
    
    func logInButtonTapped(emailAddress: String, password: String) async throws {
        do {
            loginButtonIsDisabled = true
            try await Auth.auth().signIn(withEmail: emailAddress, password: password)
        } catch {
            loginErrorShowing = true
            loginErrorMessage = error.localizedDescription
            loginButtonIsDisabled = false
            throw error
        }
    }
}
