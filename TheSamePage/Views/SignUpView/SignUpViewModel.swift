//
//  SignUpViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation
import UIKit.UIImage

class SignUpViewModel: ObservableObject {
    enum SignUpViewModelError: Error {
        case firebaseAuthError(message: String)
        case firestoreError(message: String)
        case firebaseStorageError(message: String)
        case unexpectedNilValue(value: String)
    }
    
    @Published var emailAddress = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var signUpButtonIsDisabled = false
    
    /// Creates and logs in a user in Firebase Auth with the email address and password entered by the user.
    ///
    /// If creating the user succeeds, then a subsequent method is called from within this method that will
    /// handle creating the user object.
    /// - Parameter image: The profile image selected by the user.
    func registerUser(withImage image: UIImage?) async throws {
        do {
            _ = try await Auth.auth().createUser(withEmail: emailAddress, password: password)
            try await DatabaseService.shared.createUserObject(firstName: firstName, lastName: lastName, image: image)
        } catch {
            throw SignUpViewModelError.firebaseAuthError(message: "Failed to create new user.")
        }
    }
}
