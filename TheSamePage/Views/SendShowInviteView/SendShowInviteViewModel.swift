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
    @Published var sendButtonIsDisabled = false

    @Published var invalidInviteAlertIsShowing = false
    @Published var invalidInviteAlertText = ""
    @Published var errorAlertIsShowing = false
    @Published var errorAlertText = ""

    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                sendButtonIsDisabled = true
            case .workCompleted:
                showInviteSentSuccessfully = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                sendButtonIsDisabled = false
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
            invalidInviteAlertText = ErrorMessageConstants.showLineupIsFull
            invalidInviteAlertIsShowing = true
            return nil
        }
            
        do {
            let senderUsername = try await AuthController.getLoggedInUsername()

            let showInvite = ShowInvite(
                id: "",
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

            return try await DatabaseService.shared.sendShowInvite(invite: showInvite)
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
