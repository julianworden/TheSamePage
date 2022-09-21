//
//  LoginViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class LoginViewModel: ObservableObject {
    enum LoginViewModelError: Error {
        case authError(message: String)
    }
    
    @Published var emailAddress = ""
    @Published var password = ""
    
    @Published var loginWasSuccessful = false
    @Published var loginButtonIsDisabled = false
    
    func logInButtonTapped() async throws {
        do {
            try await Auth.auth().signIn(withEmail: emailAddress, password: password)
        } catch {
            throw LoginViewModelError.authError(message: "Sign In Failed")
        }
    }
}
