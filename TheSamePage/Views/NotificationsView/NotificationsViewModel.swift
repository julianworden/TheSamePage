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
//    @Published var fetchedBandInvites = [BandInvite]()
//    @Published var fetchedShowInvites = [ShowInvite]()
    @Published var fetchedNotifications = [AnyUserNotification]()
    @Published var selectedNotificationType = NotificationType.bandInvite
    
    let db = Firestore.firestore()
    var notificationsListener: ListenerRegistration?
    
    func getNotifications() throws {
        notificationsListener = db
            .collection(FbConstants.users)
            .document(AuthController.getLoggedInUid())
            .collection(FbConstants.notifications)
            .addSnapshotListener { snapshot, error in
                if snapshot != nil && error == nil {
                    // Do not check if snapshot.documents.isEmpty or else deleting the final notification
                    // in the array will not update the UI in realtime.
                    
                    Task {
                        self.fetchedNotifications = try await DatabaseService.shared.getNotifications()
                    }
                }
        }
    }
    
    func handleNotification(anyUserNotification: AnyUserNotification, withAction action: NotificationAction) {
        Task {
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
        }
    }
    
    func acceptBandInvite(bandInvite: BandInvite) async throws {
        let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
        let band = try await DatabaseService.shared.getBand(with: bandInvite.bandId)
        let bandMember = BandMember(uid: loggedInUser.id, role: bandInvite.recipientRole, username: loggedInUser.username, fullName: loggedInUser.fullName)
        try await DatabaseService.shared.addUserToBand(add: loggedInUser, as: bandMember, to: band, withBandInvite: bandInvite)
    }
    
    func acceptShowInvite(showInvite: ShowInvite) async throws {
        let band = try await DatabaseService.shared.getBand(with: showInvite.bandId)
        let showParticipant = ShowParticipant(name: showInvite.bandName, bandId: showInvite.bandId, showId: showInvite.showId)
        
        try await DatabaseService.shared.addBandToShow(add: band, as: showParticipant, withShowInvite: showInvite)
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
