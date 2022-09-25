//
//  UserViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
class UserController: ObservableObject {
    enum UserControllerError: Error {
        case firestoreError(message: String)
        case firebaseAuthError(message: String)
    }
    
    // TODO: Clear these values when user signs out
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var emailAddress: String?
    @Published var profileImageUrl: String?
    @Published var createdBand: Band?
    @Published var bands: [Band]?

    func initializeUser() async throws {
        // If these properties have values, there's no reason to make the database call
        // TODO: Add this line when user values are cleared on log out: guard firstName == nil && lastName == nil else { return }
        
        let user = try await DatabaseService.shared.getLoggedInUser()
        
        firstName = user.firstName
        lastName = user.lastName
        emailAddress = user.emailAddress
        profileImageUrl = user.profileImageUrl
    }
    
    // TODO: Incorporate a listener to this so the bands array is updated when the user joins a new band
    func getBands() async throws {
        guard !AuthController.userIsLoggedOut() else { throw UserControllerError.firebaseAuthError(message: "User not logged in") }
        
        let bandIds = try await DatabaseService.shared.getIdsForJoinedBands(forUserUid: AuthController.getLoggedInUid())
        
        // Prevents "Member Of" section from showing if user is not a member of any bands.
        if !bandIds.isEmpty {
            bands = try await DatabaseService.shared.getBands(withBandIds: bandIds)
        }
    }
}
