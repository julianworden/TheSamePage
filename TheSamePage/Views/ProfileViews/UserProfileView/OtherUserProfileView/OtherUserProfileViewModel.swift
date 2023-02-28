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
    @Published var user: User?
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var emailAddress: String?
    @Published var profileImageUrl: String?
    @Published var bands = [Band]()
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    var shortenedDynamicLink: URL?
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                if viewState != .dataLoaded && viewState != .dataLoading {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }
    let isPresentedModally: Bool
    
    init(user: User?, uid: String? = nil, bandMember: BandMember? = nil, isPresentedModally: Bool = false) {
        self.isPresentedModally = isPresentedModally
        
        Task {
            if let user {
                await initializeUser(user: user)
                return
            }

            if let bandMember,
               let convertedUser = await convertBandMemberToUser(bandMember: bandMember) {
                await initializeUser(user: convertedUser)
                return
            }

            if let uid,
               let convertedUser = await convertUidToUser(uid: uid) {
                await initializeUser(user: convertedUser)
                return
            }
        }
    }
    
    func initializeUser(user: User) async {
        do {
            self.user = user
            self.firstName = user.firstName
            self.lastName = user.lastName
            self.emailAddress = user.emailAddress
            self.profileImageUrl = user.profileImageUrl
            self.shortenedDynamicLink = await createDynamicLinkForUser()
            self.bands = try await getBands(forUser: user)
            
            viewState = .dataLoaded
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func convertUidToUser(uid: String) async -> User? {
        do {
            return try await DatabaseService.shared.getUser(withUid: uid)
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
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
        return try await DatabaseService.shared.getJoinedBands(withUid: user.id)
    }

    func createDynamicLinkForUser() async -> URL? {
        guard let user else {
            print("User object cannot be nil before generating Dynamic Link for user.")
            return nil
        }

        return await DynamicLinkController.shared.createDynamicLink(ofType: .user, for: user)
    }
}
