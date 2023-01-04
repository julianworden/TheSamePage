//
//  OtherUserProfileViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import Foundation

@MainActor
final class OtherUserProfileViewModel: ObservableObject {
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
    @Published var bands = [Band]()
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                if viewState != .dataLoaded && viewState != .dataLoading {
                    print("Unknown viewState passed to OtherUserProfileViewModel: \(viewState)")
                }
            }
        }
    }
    
    var loggedInUserIsBandAdmin: Bool {
        return AuthController.getLoggedInUid() == user?.id
    }
    
    init(user: User?, bandMember: BandMember? = nil) {
        Task {
            if let user {
                await initializeUser(user: user)
            }
            
            if let bandMember,
               let convertedUser = await convertBandMemberToUser(bandMember: bandMember) {
                await initializeUser(user: convertedUser)
            }
        }
    }
    
    func initializeUser(user: User) async {
        // TODO: Add this line when user values are cleared on log out: guard firstName == nil && lastName == nil else { return }
        do {
            self.user = user
            self.firstName = user.firstName
            self.lastName = user.lastName
            self.emailAddress = user.emailAddress
            self.profileImageUrl = user.profileImageUrl
            self.bands = try await getBands(forUser: user)
            
            viewState = .dataLoaded
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func convertBandMemberToUser(bandMember: BandMember) async -> User? {
        do {
            return try await DatabaseService.shared.convertBandMemberToUser(bandMember: bandMember)
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }
    
    // TODO: Incorporate a listener to this so the bands array is updated when the user joins a new band
    func getBands(forUser user: User) async throws -> [Band] {
        return try await DatabaseService.shared.getBands(withUid: user.id)
    }
}
