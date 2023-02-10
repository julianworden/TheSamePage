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
    @Published var fetchedNotifications = [AnyUserNotification]()
    @Published var selectedNotificationType = NotificationType.bandInvite
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
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
    var notificationsListener: ListenerRegistration?

    // TODO: Add separate method for fetching notifications that already exist, also call the getNotifications

    func getNotifications() {
        notificationsListener = db
            .collection(FbConstants.users)
            .document(AuthController.getLoggedInUid())
            .collection(FbConstants.notifications)
            .addSnapshotListener { snapshot, error in
                if snapshot != nil && error == nil {
                    // Do not check if snapshot.documents.isEmpty or else deleting the final notification
                    // in the array will not update the UI in realtime.
                    var notificationsAsAnyUserNotification = [AnyUserNotification]()

                    for document in snapshot!.documents {
                        if let bandInvite = try? document.data(as: BandInvite.self) {
                            let bandInviteAsAnyUserNotification = AnyUserNotification(id: bandInvite.id, notification: bandInvite)
                            notificationsAsAnyUserNotification.append(bandInviteAsAnyUserNotification)
                        } else if let showInvite = try? document.data(as: ShowInvite.self) {
                            let showInviteAsAnyUserNotification = AnyUserNotification(id: showInvite.id, notification: showInvite)
                            notificationsAsAnyUserNotification.append(showInviteAsAnyUserNotification)
                        } else if let showApplication = try? document.data(as: ShowApplication.self) {
                            let showApplicationAsAnyUserNotification = AnyUserNotification(id: showApplication.id, notification: showApplication)
                            notificationsAsAnyUserNotification.append(showApplicationAsAnyUserNotification)
                        }
                    }

                    self.fetchedNotifications = notificationsAsAnyUserNotification
                    self.fetchedNotifications.isEmpty ? (self.viewState = .dataNotFound) : (self.viewState = .dataLoaded)

                } else if error != nil {
                    self.viewState = .error(message: "Failed to fetch up-to-date notifications. System error: \(error!.localizedDescription)")
                }
        }
    }
    
    func handleNotification(anyUserNotification: AnyUserNotification, withAction action: NotificationAction) async {
        do {
            guard action != .decline else {
                try await declineNotification(notification: anyUserNotification.notification)
                return
            }

            if let bandInvite = anyUserNotification.notification as? BandInvite {
                try await acceptBandInvite(bandInvite: bandInvite)
                try await FirebaseFunctionsController.notifyAcceptedBandInvite(
                    recipientFcmToken: bandInvite.senderFcmToken,
                    message: bandInvite.acceptanceMessage
                )
            } else if let showInvite = anyUserNotification.notification as? ShowInvite {
                try await acceptShowInvite(showInvite: showInvite)
                try await FirebaseFunctionsController.notifyAcceptedShowInvite(
                    recipientFcmToken: showInvite.senderFcmToken,
                    message: showInvite.acceptanceMessage
                )
            } else if let showApplication = anyUserNotification.notification as? ShowApplication {
                try await acceptShowApplication(showApplication: showApplication)
                try await FirebaseFunctionsController.notifyAcceptedShowApplication(
                    recipientFcmToken: showApplication.senderFcmToken,
                    message: showApplication.acceptanceMessage
                )
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func acceptBandInvite(bandInvite: BandInvite) async throws {
        let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
        let band = try await DatabaseService.shared.getBand(with: bandInvite.bandId)
        let bandMember = BandMember(
            id: "",
            dateJoined: Date.now.timeIntervalSince1970,
            uid: loggedInUser.id,
            role: bandInvite.recipientRole,
            username: loggedInUser.username,
            fullName: loggedInUser.fullName
        )
        try await DatabaseService.shared.addUserToBand(add: loggedInUser, as: bandMember, to: band, withBandInvite: bandInvite)
    }
    
    func acceptShowInvite(showInvite: ShowInvite) async throws {
        guard try await showInviteOrApplicationIsStillValid(showInvite: showInvite, showApplication: nil) else {
            try await DatabaseService.shared.deleteNotification(withId: showInvite.id)
            viewState = .error(message: ErrorMessageConstants.showLineupIsFullOnAcceptShowInvite)
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
    }

    func acceptShowApplication(showApplication: ShowApplication) async throws {
        guard try await showInviteOrApplicationIsStillValid(showInvite: nil, showApplication: showApplication) else {
            try await DatabaseService.shared.deleteNotification(withId: showApplication.id)
            viewState = .error(message: ErrorMessageConstants.showLineupIsFullOnAcceptShowApplication)
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
    }

    func showInviteOrApplicationIsStillValid(showInvite: ShowInvite?, showApplication: ShowApplication?) async throws -> Bool {
        if let showInvite {
            let show = try await DatabaseService.shared.getShow(showId: showInvite.showId)
            return show.lineupIsFull == false
        } else if let showApplication {
            let show = try await DatabaseService.shared.getShow(showId: showApplication.showId)
            return show.lineupIsFull == false
        }

        throw LogicError.unexpectedNilValue(message: "Failed to determine if notification is valid. Please restart The Same Page and try again.")
    }

    func declineNotification(notification: any UserNotification) async throws {
        try await DatabaseService.shared.deleteNotification(withId: notification.id)
    }
    
    func removeListeners() {
        notificationsListener?.remove()
    }
}
