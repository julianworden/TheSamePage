//
//  ProfileViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import Foundation

@MainActor
class UserProfileViewModel: ObservableObject {
    enum UserProfileViewModelError: Error {
        case firebaseAuthError(message: String)
    }
    
    @Published var sendBandInviteSheetIsShowing = false
    
    /// The user being displayed. When this value is nil, the logged in user is viewing their own profile
    @Published var user: User?
    /// The band that the user will be invited to join if their invite button is tapped.
    @Published var band: Band?
    /// The bandMember for which the Profile is a representation. This is necessary for when a
    /// user is selected from the BandProfile's Members section.
    @Published var bandMember: BandMember?
    
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var emailAddress: String?
    @Published var profileImageUrl: String?
    @Published var bands: [Band]?
    
    var loggedInUserIsBandAdmin: Bool {
        return AuthController.getLoggedInUid() == user?.id
    }
    
    init(user: User?, band: Band?, bandMember: BandMember?) {
        if let user {
            self.user = user
        }
        
        if let band {
            self.band = band
        }
        
        if let bandMember {
            self.bandMember = bandMember
        }
        
        Task {
            do {
                // This is needed because HomeView doesn't call initialize user onAppear if the user is onboarding. This is expected.
                if user == nil && bandMember == nil {
                    try await initializeUser(user: nil)
                    try await getBands(forUser: nil)
                } else if user != nil && bandMember == nil {
                    try await initializeUser(user: user)
                    try await getBands(forUser: user)
                } else if user == nil && bandMember != nil {
                    let convertedUser = try await convertBandMemberToUser(bandMember: bandMember!)
                    self.user = convertedUser
                    try await initializeUser(user: convertedUser)
                    try await getBands(forUser: convertedUser)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func initializeUser(user: User?) async throws {
        // If these properties have values, there's no reason to make the database call
        // TODO: Add this line when user values are cleared on log out: guard firstName == nil && lastName == nil else { return }
        
        if let user {
            firstName = user.firstName
            lastName = user.lastName
            emailAddress = user.emailAddress
            profileImageUrl = user.profileImageUrl
        } else {
            let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
            
            firstName = loggedInUser.firstName
            lastName = loggedInUser.lastName
            emailAddress = loggedInUser.emailAddress
            profileImageUrl = loggedInUser.profileImageUrl
        }
        
    }
    
    func convertBandMemberToUser(bandMember: BandMember) async throws -> User {
        return try await DatabaseService.shared.convertBandMemberToUser(bandMember: bandMember)
    }
    
    // TODO: Incorporate a listener to this so the bands array is updated when the user joins a new band
    @MainActor
    func getBands(forUser user: User?) async throws {
        guard !AuthController.userIsLoggedOut() else { throw UserProfileViewModelError.firebaseAuthError(message: "User not logged in") }
        
        var bandIds = [String]()
        
        if user != nil && user?.id != nil {
            bandIds = try await DatabaseService.shared.getIdsForJoinedBands(forUserUid: user!.id!)
        } else {
            bandIds = try await DatabaseService.shared.getIdsForJoinedBands(forUserUid: AuthController.getLoggedInUid())
        }
        
        // Prevents "Member Of" section from showing if user is not a member of any bands.
        if !bandIds.isEmpty {
            bands = try await DatabaseService.shared.getBands(withBandIds: bandIds)
        }
    }
    
    func logOut() throws {
        firstName = nil
        lastName = nil
        emailAddress = nil
        profileImageUrl = nil
        bands = nil
        
        do {
            try AuthController.logOut()
        } catch {
            throw UserProfileViewModelError.firebaseAuthError(message: "Failed to log out")
        }
    }
}
