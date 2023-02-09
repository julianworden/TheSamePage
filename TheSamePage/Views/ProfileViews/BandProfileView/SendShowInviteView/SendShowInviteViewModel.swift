//
//  SendShowInviteViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import Foundation

@MainActor
final class SendShowInviteViewModel: ObservableObject {
    var userShows = [Show]()
    @Published var selectedShow: Show?
    
    /// The band that is being invited to join the show.
    let band: Band

    @Published var showInviteSentSuccessfully = false
    @Published var buttonsAreDisabled = false

    @Published var invalidInviteAlertIsShowing = false
    @Published var invalidInviteAlertText = ""
    @Published var errorAlertIsShowing = false
    @Published var errorAlertText = ""

    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                showInviteSentSuccessfully = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                if viewState != .dataNotFound && viewState != .dataLoaded && viewState != .dataLoading {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }
    
    init(band: Band) {
        self.band = band
    }

    @discardableResult func sendShowInvite() async -> String? {
        guard !selectedShow!.bandIds.contains(band.id) else {
            invalidInviteAlertText = ErrorMessageConstants.bandIsAlreadyPlayingShow
            invalidInviteAlertIsShowing = true
            return nil
        }
        
        guard !selectedShow!.lineupIsFull else {
            invalidInviteAlertText = ErrorMessageConstants.showLineupIsFullOnSendShowInvite
            invalidInviteAlertIsShowing = true
            return nil
        }

        viewState = .performingWork
            
        do {
            let senderUsername = try await AuthController.getLoggedInUsername()
            let senderFcmToken = try await AuthController.getLoggedInFcmToken()
            let recipientFcmToken = try await DatabaseService.shared.getFcmToken(forUserWithUid: band.adminUid)

            let showInvite = ShowInvite(
                id: "",
                recipientFcmToken: recipientFcmToken,
                senderFcmToken: senderFcmToken,
                dateSent: Date.now.timeIntervalSince1970,
                notificationType: NotificationType.showInvite.rawValue,
                recipientUid: band.adminUid,
                bandName: band.name,
                bandId: band.id,
                showId: selectedShow!.id,
                showName: selectedShow!.name,
                showDate: selectedShow!.date,
                showVenue: selectedShow!.venue,
                senderUsername: senderUsername,
                hasFood: selectedShow!.hasFood,
                hasBar: selectedShow!.hasBar,
                is21Plus: selectedShow!.is21Plus,
                message: "\(senderUsername) is inviting \(band.name) to play \(selectedShow!.name) at \(selectedShow!.venue) on \(selectedShow!.formattedDate)"
            )

            let showInviteId = try await DatabaseService.shared.sendShowInvite(invite: showInvite)
            viewState = .workCompleted
            return showInviteId
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }
    
    func getHostedShows() async {
        do {
            userShows = try await DatabaseService.shared.getLoggedInUserHostedShows()
            
            if !userShows.isEmpty {
                viewState = .dataLoaded
                selectedShow = userShows.first!
            } else {
                viewState = .dataNotFound
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
