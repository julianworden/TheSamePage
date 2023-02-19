//
//  SendBandInviteViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/25/22.
//

import FirebaseAuth
import Foundation

@MainActor
final class SendBandInviteViewModel: ObservableObject {
    /// The bands of which the logged in user is the admin.
    var adminBands = [Band]()
    /// The band that the user will be invited to join.
    @Published var selectedBand: Band?
    @Published var recipientRole = Instrument.vocals
    @Published var buttonsAreDisabled = false
    @Published var bandInviteSentSuccessfully = false
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                bandInviteSentSuccessfully = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                if viewState != .dataNotFound && viewState != .dataLoaded {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }
    
    /// The user who will be receiving the band invite.
    let user: User
    
    init(user: User) {
        self.user = user
    }

    func getLoggedInUserAdminBands() async {
        do {
            adminBands = try await DatabaseService.shared.getAdminBands(withUid: AuthController.getLoggedInUid())

            if !adminBands.isEmpty {
                selectedBand = adminBands.first!
                viewState = .dataLoaded
            } else {
                viewState = .dataNotFound
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    // TODO: Make it so that this method throws an error if the user being invited is already in the band
    func sendBandInvite() async -> String? {
        guard let selectedBand else {
            viewState = .error(message: "There was an error sending this band invite. Please ensure you have an internet connection, restart The Same Page, and try again.")
            return nil
        }

        do {
            viewState = .performingWork
            let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
            
            let invite = BandInvite(
                id: "",
                recipientFcmToken: user.fcmToken,
                recipientUsername: user.username,
                sentTimestamp: Date.now.timeIntervalSince1970,
                notificationType: NotificationType.bandInvite.rawValue,
                senderUid: loggedInUser.id,
                recipientUid: user.id,
                recipientRole: recipientRole.rawValue,
                bandId: selectedBand.id,
                senderUsername: loggedInUser.username,
                senderBand: selectedBand.name,
                message: "\(loggedInUser.username) is inviting you to join \(selectedBand.name)."
            )
            let bandInviteId = try await DatabaseService.shared.sendBandInvite(invite: invite)
            viewState = .workCompleted
            return bandInviteId
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }
}
