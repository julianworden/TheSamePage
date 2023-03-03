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
    @Published var selectedTab = SelectedUserProfileTab.bands
    @Published var bands = [Band]()
    @Published var shows = [Show]()
    
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
        self.user = user
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.emailAddress = user.emailAddress
        self.profileImageUrl = user.profileImageUrl
        self.shortenedDynamicLink = await createDynamicLinkForUser()
        await getAllUserBands()
        await getAllUserShows()

        viewState = .dataLoaded
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

    func getAllUserBands() async {
        guard let user else {
            viewState = .error(message: "Failed to fetch up-to-date user info. Please ensure you have an internet connection, restart The Same Page, and try again.")
            return
        }

        do {
            self.bands = try await DatabaseService.shared.getAllBands(withUid: user.id)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getAllUserShows() async {
        guard let user else {
            viewState = .error(message: "Failed to fetch up-to-date user info. Please ensure you have an internet connection, restart The Same Page, and try again.")
            return
        }

        do {
            self.shows = try await DatabaseService.shared.getAllShows(withUid: user.id)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func createDynamicLinkForUser() async -> URL? {
        guard let user else {
            print("User object cannot be nil before generating Dynamic Link for user.")
            return nil
        }

        return await DynamicLinkController.shared.createDynamicLink(ofType: .user, for: user)
    }
}
