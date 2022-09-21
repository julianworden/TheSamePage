//
//  UserViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class UserController: ObservableObject {
    enum UserControllerError: Error {
        case firestoreError(message: String)
    }
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var emailAddress = ""
    @Published var profileImageUrl = ""
    @Published var bands = [Band]()
    
    @MainActor
    func initializeUser() async throws {
        let user = try await DatabaseService.shared.initializeUser()
        
        firstName = user.firstName
        lastName = user.lastName
        emailAddress = user.emailAddress ?? ""
        profileImageUrl = user.profileImageUrl ?? ""
    }
    
    func getBands() {
        bands = User.example.bands ?? []
    }
}
