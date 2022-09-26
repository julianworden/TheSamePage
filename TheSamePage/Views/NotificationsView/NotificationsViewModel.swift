//
//  NotificationsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import FirebaseFirestore
import Foundation

class NotificationsViewModel: ObservableObject {
    @Published var fetchedNotifications = [BandInvite]()
    
    let db = Firestore.firestore()
    var notificationsListener: ListenerRegistration?
    
    func getNotifications() throws {
        notificationsListener = db.collection("users").document(AuthController.getLoggedInUid()).collection("bandInvites").addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                Task { @MainActor in
                    self.fetchedNotifications = try await DatabaseService.shared.getNotifications()
                }
            }
        }
    }
    
    func removeListeners() {
        notificationsListener?.remove()
    }
}
