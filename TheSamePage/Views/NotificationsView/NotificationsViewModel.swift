//
//  NotificationsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import FirebaseFirestore
import Foundation

class NotificationsViewModel: ObservableObject {
    @Published var fetchedBandInvites = [BandInvite]()
    @Published var fetchedShowInvites = [ShowInvite]()
    @Published var selectedNotificationType = NotificationType.bandInvite
    
    let db = Firestore.firestore()
    var bandInvitesListener: ListenerRegistration?
    var showInvitesListener: ListenerRegistration?
    
    func getBandInvites() throws {
        bandInvitesListener = db.collection("users").document(AuthController.getLoggedInUid()).collection("bandInvites").addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                Task { @MainActor in
                    self.fetchedBandInvites = try await DatabaseService.shared.getBandInvites()
                }
            }
        }
    }
    
    func getShowInvites() throws {
        showInvitesListener = db.collection("users").document(AuthController.getLoggedInUid()).collection("showInvites").addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                Task { @MainActor in
                    self.fetchedShowInvites = try await DatabaseService.shared.getShowInvites()
                }
            }
        }
    }
    
    func removeListeners() {
        bandInvitesListener?.remove()
        showInvitesListener?.remove()
    }
}
