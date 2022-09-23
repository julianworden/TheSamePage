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
    
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var emailAddress: String?
    @Published var profileImageUrl: String?
    @Published var selectedBand: Band?
    
    @MainActor
    func initializeUser() async throws {
        let user = try await DatabaseService.shared.getLoggedInUser()
        
        firstName = user.firstName
        lastName = user.lastName
        emailAddress = user.emailAddress
        profileImageUrl = user.profileImageUrl
    }
}
