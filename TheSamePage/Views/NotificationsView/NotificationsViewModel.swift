//
//  NotificationsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import FirebaseFirestore
import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var buttonsAreDisabled = false
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                buttonsAreDisabled = false
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                if viewState != .dataLoaded && viewState != .dataNotFound {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    let db = Firestore.firestore()
    
    func handleNotification(anyUserNotification: AnyUserNotification, withAction action: NotificationAction) async {
        do {
            viewState = .performingWork
            
            guard action != .decline else {
                try await declineNotification(notification: anyUserNotification.notification)
                viewState = .workCompleted
                return
            }

            if let bandInvite = anyUserNotification.notification as? BandInvite {
                try await acceptBandInvite(bandInvite: bandInvite)
                if let senderFcmToken = try await DatabaseService.shared.getFcmToken(forUserWithUid: bandInvite.senderUid) {
                    try await FirebaseFunctionsController.notifyAcceptedBandInvite(
                        recipientFcmToken: senderFcmToken,
                        message: bandInvite.acceptanceMessage,
                        bandId: bandInvite.bandId
                    )
                }
                return
            } else if let showInvite = anyUserNotification.notification as? ShowInvite {
                try await acceptShowInvite(showInvite: showInvite)
                if let senderFcmToken = try await DatabaseService.shared.getFcmToken(forUserWithUid: showInvite.senderUid) {
                    try await FirebaseFunctionsController.notifyAcceptedShowInvite(
                        recipientFcmToken: senderFcmToken,
                        message: showInvite.acceptanceMessage,
                        showId: showInvite.showId
                    )
                }
                return
            } else if let showApplication = anyUserNotification.notification as? ShowApplication {
                try await acceptShowApplication(showApplication: showApplication)
                if let senderFcmToken = try await DatabaseService.shared.getFcmToken(forUserWithUid: showApplication.senderUid) {
                    try await FirebaseFunctionsController.notifyAcceptedShowApplication(
                        recipientFcmToken: senderFcmToken,
                        message: showApplication.acceptanceMessage,
                        showId: showApplication.showId
                    )
                }
                return
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func acceptBandInvite(bandInvite: BandInvite) async throws {
        guard try await bandInviteIsStillValid(bandInvite: bandInvite) else {
            try await DatabaseService.shared.deleteNotification(withId: bandInvite.id)
            viewState = .error(message: ErrorMessageConstants.invalidBandInvite)
            return
        }

        let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
        let band = try await DatabaseService.shared.getBand(with: bandInvite.bandId)
        let bandMember = BandMember(
            id: "",
            dateJoined: Date.now.timeIntervalSince1970,
            uid: loggedInUser.id,
            role: bandInvite.recipientRole,
            username: loggedInUser.name,
            fullName: loggedInUser.fullName
        )
        try await DatabaseService.shared.addUserToBand(add: loggedInUser, as: bandMember, to: band, withBandInvite: bandInvite)

        viewState = .workCompleted
    }

    func bandInviteIsStillValid(bandInvite: BandInvite) async throws -> Bool {
        do {
            let band = try await DatabaseService.shared.getBand(with: bandInvite.bandId)
            return !band.memberUids.contains(bandInvite.recipientUid)
        } catch {
            viewState = .error(message: error.localizedDescription)
            return false
        }
    }
    
    func acceptShowInvite(showInvite: ShowInvite) async throws {
        guard try await showInviteOrApplicationIsStillValid(showInvite: showInvite, showApplication: nil) else {
            try await DatabaseService.shared.deleteNotification(withId: showInvite.id)
            viewState = .error(message: ErrorMessageConstants.invalidShowInvite)
            return
        }

        let band = try await DatabaseService.shared.getBand(with: showInvite.bandId)

        let showParticipant = ShowParticipant(
            name: showInvite.bandName,
            bandId: showInvite.bandId,
            bandAdminUid: band.adminUid,
            showId: showInvite.showId
        )
        
        try await DatabaseService.shared.addBandToShow(add: band, as: showParticipant, withShowInvite: showInvite)

        viewState = .workCompleted
    }

    func acceptShowApplication(showApplication: ShowApplication) async throws {
        guard try await showInviteOrApplicationIsStillValid(showInvite: nil, showApplication: showApplication) else {
            try await DatabaseService.shared.deleteNotification(withId: showApplication.id)
            viewState = .error(message: ErrorMessageConstants.invalidShowApplication)
            return
        }

        let band = try await DatabaseService.shared.getBand(with: showApplication.bandId)

        let showParticipant = ShowParticipant(
            name: showApplication.bandName,
            bandId: showApplication.bandId,
            bandAdminUid: band.adminUid,
            showId: showApplication.showId
        )

        try await DatabaseService.shared.addBandToShow(add: band, as: showParticipant, withShowApplication: showApplication)

        viewState = .workCompleted
    }

    func showInviteOrApplicationIsStillValid(showInvite: ShowInvite?, showApplication: ShowApplication?) async throws -> Bool {
        if let showInvite {
            let show = try await DatabaseService.shared.getShow(showId: showInvite.showId)
            return !show.lineupIsFull && !show.bandIds.contains(showInvite.bandId)
        } else if let showApplication {
            let show = try await DatabaseService.shared.getShow(showId: showApplication.showId)
            return !show.lineupIsFull && !show.bandIds.contains(showApplication.bandId)
        }

        throw LogicError.unexpectedNilValue(message: "Failed to determine if notification is valid. Please restart The Same Page and try again.")
    }

    func declineNotification(notification: any UserNotification) async throws {
        try await DatabaseService.shared.deleteNotification(withId: notification.id)

        viewState = .workCompleted
    }
}
