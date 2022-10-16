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
    
    @Published var username = ""
    @Published var emailAddress = ""
    @Published var profileImage: UIImage?
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber: String?
    @Published var userIsInABand = false
    
    /// Creates and registers a user in Firebase Auth with the email address and password entered by the user.
    ///
    /// Once the user is created in Firebase Auth, a new user object is created and passed to the DatabaseService,
    /// which will add that new user object to the users collection in Firestore.
    /// - Parameter image: The profile image selected by the user.
    func registerUser() async throws {
        var newUser: User
        var uid: String?
        
        do {
            let result = try await Auth.auth().createUser(withEmail: emailAddress, password: password)
            uid = result.user.uid
        } catch {
            throw SignUpViewModelError.firebaseAuthError(message: "Failed to create user.")
        }
        
        if let profileImage {
            let imageUrl = try await DatabaseService.shared.uploadImage(image: profileImage)
            newUser = User(
                id: uid,
                username: username,
                firstName: firstName,
                lastName: lastName,
                profileImageUrl: imageUrl,
                phoneNumber: phoneNumber,
                emailAddress: emailAddress
            )
        } else {
            newUser = User(
                id: uid,
                username: username,
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber,
                emailAddress: emailAddress
            )
        }
        
        try await DatabaseService.shared.createUserObject(user: newUser)
    }
}
