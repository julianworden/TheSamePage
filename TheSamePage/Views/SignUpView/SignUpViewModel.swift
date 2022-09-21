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
    @Published var userIsInABand = false
    @Published var signUpButtonIsDisabled = false
    
    /// Creates and registers a user in Firebase Auth with the email address and password entered by the user.
    ///
    /// Once the user is created in Firebase Auth, a new user object is created and passed to the DatabaseService,
    /// which will add that new user object to the users collection in Firestore.
    /// - Parameter image: The profile image selected by the user.
    func registerUser(withImage image: UIImage?) async throws {
        var newUser: User
        
        do {
            _ = try await Auth.auth().createUser(withEmail: emailAddress, password: password)
        } catch {
            throw SignUpViewModelError.firebaseAuthError(message: "Failed to create user.")
        }
        
        // TODO: Allow the method to still create the user if the image upload fails.
        if let image {
            let imageUrl = try await DatabaseService.shared.uploadImage(image: image)
            newUser = User(
                firstName: firstName,
                lastName: lastName,
                profileImageUrl: imageUrl,
                phoneNumber: nil,
                emailAddress: nil,
                bands: nil
            )
        } else {
            newUser = User(
                firstName: firstName,
                lastName: lastName,
                profileImageUrl: nil,
                phoneNumber: nil,
                emailAddress: nil,
                bands: nil
            )
        }
        
        try await DatabaseService.shared.createUserObject(user: newUser)
    }
}
