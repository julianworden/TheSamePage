//
//  SignUpViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import FirebaseAuth
import Foundation

class SignUpViewModel: ObservableObject {
    enum SignUpViewModelError: Error {
        case firebaseAuthError(message: String)
    }
    
    @Published var emailAddress = ""
    @Published var password = ""
    
    func createUserAccount() async throws {
        do {
            _ = try await Auth.auth().createUser(withEmail: emailAddress, password: password)
        } catch {
            throw SignUpViewModelError.firebaseAuthError(message: "Failed to create new user.")
        }
    }
}
