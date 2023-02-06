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
            if let bandInvite = anyUserNotification.notification as? BandInvite {
                if action == .accept {
                    try await acceptBandInvite(bandInvite: bandInvite)
                } else {
                    try await declineBandInvite(bandInvite: bandInvite)
                }
                
            } else if let showInvite = anyUserNotification.notification as? ShowInvite {
                if action == .accept {
                    try await acceptShowInvite(showInvite: showInvite)
                } else {
                    try await declineShowInvite(showInvite: showInvite)
                }
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
        guard try await showInviteIsStillValid(showInvite: showInvite) else {
            try await DatabaseService.shared.deleteShowInvite(showInvite: showInvite)
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

    func showInviteIsStillValid(showInvite: ShowInvite) async throws -> Bool {
        let show = try await DatabaseService.shared.getShow(showId: showInvite.showId)

        return show.lineupIsFull == false
    }

    func declineBandInvite(bandInvite: BandInvite) async throws {
        try await DatabaseService.shared.deleteBandInvite(bandInvite: bandInvite)
    }

    func declineShowInvite(showInvite: ShowInvite) async throws {
        try await DatabaseService.shared.deleteShowInvite(showInvite: showInvite)
    }
    
    func removeListeners() {
        notificationsListener?.remove()
    }
}
