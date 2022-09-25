//
//  ProfileViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import Foundation

class UserProfileViewModel: ObservableObject {
    enum UserProfileViewModelError: Error {
        case firebaseAuthError(message: String)
    }
    
    @Published var streamingActionSheetIsShowing = false
    
    /// The user being displayed. When this value is nil, the logged in user is viewing their own profile
    @Published var user: User?
    /// The band that the user will be invited to join if their invite button is tapped.
    @Published var band: Band?
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var emailAddress: String?
    @Published var profileImageUrl: String?
    @Published var bands: [Band]?
    
    var loggedInUserIsBandAdmin: Bool {
        return AuthController.getLoggedInUid() == user?.id
    }
    
    init(user: User?, band: Band?) {
        self.user = user
        self.band = band
        
        Task {
            do {
                // This is needed because HomeView doesn't call initialize user onAppear if the user is onboarding. This is expected.
                if user == nil {
                    try await initializeUser(user: nil)
                    try await getBands(forUser: nil)
                } else {
                    try await initializeUser(user: user)
                    try await getBands(forUser: user)
                }
            } catch {
                print(error)
            }
        }
    }
    
    func sendBandInviteNotification() throws {
        if user != nil {
            // TODO: Get rid of force unwrapping
            let invite = BandInvite(
                recipientUid: user!.id!,
                bandId: band!.id!,
                senderName: Auth.auth().currentUser!.email!,
                senderBand: band!.name
            )
            try DatabaseService.shared.sendBandInvite(invite: invite)
        }
    }
    
    @MainActor
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
}
