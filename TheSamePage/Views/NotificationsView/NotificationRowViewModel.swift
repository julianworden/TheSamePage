//
//  NotificationRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import Foundation

class NotificationRowViewModel: ObservableObject {
    @Published var notificationSender: String
    @Published var notificationBand: String
    
    let notification: BandInvite
    
    init(notification: BandInvite) {
        self.notification = notification
        self.notificationSender = notification.senderName
        self.notificationBand = notification.senderBand
    }
    
    func acceptBandinvite() throws {
        let user = BandMember(uid: AuthController.getLoggedInUid())
        let bandId = JoinedBand(id: notification.bandId)
        try DatabaseService.shared.addUserToBand(user, addToBandUserJoined: bandId)
    }
}
