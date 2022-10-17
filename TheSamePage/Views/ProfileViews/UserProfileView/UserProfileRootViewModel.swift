//
//  ProfileViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import Foundation

@MainActor
class UserProfileRootViewModel: ObservableObject {
    enum UserProfileViewModelError: Error {
        case firebaseAuthError(message: String)
    }
    
    /// The user being displayed. When this value is nil, the logged in user is viewing their own profile
    @Published var user: User?
    /// The bandMember for which the Profile is a representation. This is necessary for when a
    /// user is selected from the BandProfile's Members section.
    var bandMember: BandMember?
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var emailAddress: String?
    @Published var profileImageUrl: String?
    @Published var bands: [Band]?
    
    var loggedInUserIsBandAdmin: Bool {
        return AuthController.getLoggedInUid() == user?.id
    }
    
    init(user: User?, bandMember: BandMember?) {
        Task {
            if let user {
                try await initializeUser(user: user)
            }
            
            if let bandMember {
                let convertedUser = try await convertBandMemberToUser(bandMember: bandMember)
                try await initializeUser(user: convertedUser)
            }
        }
    }
    
    func initializeUser(user: User) async throws {
        // TODO: Add this line when user values are cleared on log out: guard firstName == nil && lastName == nil else { return }
        self.user = user
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.emailAddress = user.emailAddress
        self.profileImageUrl = user.profileImageUrl
        self.bands = try await getBands(forUser: user)
    }
    
    func convertBandMemberToUser(bandMember: BandMember) async throws -> User {
        return try await DatabaseService.shared.convertBandMemberToUser(bandMember: bandMember)
    }
    
    // TODO: Incorporate a listener to this so the bands array is updated when the user joins a new band
    func getBands(forUser user: User) async throws -> [Band] {
        guard !AuthController.userIsLoggedOut() else { throw UserProfileViewModelError.firebaseAuthError(message: "User not logged in") }
        
        return try await DatabaseService.shared.getBands(withUid: user.id)
        
    }
}
