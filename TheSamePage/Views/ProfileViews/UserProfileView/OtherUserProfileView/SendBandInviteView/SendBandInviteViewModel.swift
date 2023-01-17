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
    var userBands = [Band]()
    /// The band that the user will be invited to join.
    @Published var selectedBand: Band?
    @Published var recipientRole = Instrument.vocals
    @Published var sendBandInviteButtonIsDisabled = false
    @Published var bandInviteSentSuccessfully = false
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                sendBandInviteButtonIsDisabled = true
            case .workCompleted:
                bandInviteSentSuccessfully = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
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
        
        Task {
            await getLoggedInUserBands()
        }
    }
    
    func getLoggedInUserBands() async {
        do {
            let fetchedBands = try await DatabaseService.shared.getBands(withUid: AuthController.getLoggedInUid())
            userBands = fetchedBands.filter { $0.adminUid == AuthController.getLoggedInUid() }
            
            if !userBands.isEmpty {
                selectedBand = userBands.first!
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
        do {
            viewState = .performingWork
            let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
            
            // TODO: Handle error
            if let selectedBand {
                let invite = BandInvite(
                    id: "",
                    dateSent: Date.now.timeIntervalSince1970,
                    notificationType: NotificationType.bandInvite.rawValue,
                    recipientUid: user.id,
                    recipientRole: recipientRole.rawValue,
                    bandId: selectedBand.id,
                    senderUsername: loggedInUser.username,
                    senderBand: selectedBand.name,
                    message: "\(loggedInUser.username) is inviting you to join \(selectedBand.name)"
                )
                let bandInviteId = try await DatabaseService.shared.sendBandInvite(invite: invite)
                viewState = .workCompleted
                return bandInviteId
            }

            return nil
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }
}
