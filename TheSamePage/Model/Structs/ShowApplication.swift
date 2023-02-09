//
//  ShowApplication.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/8/23.
//

import FirebaseFirestoreSwift
import Foundation

struct ShowApplication: UserNotification {
    var id: String
    var recipientFcmToken: String?
    var senderFcmToken: String?
    let notificationType: String
    let bandName: String
    let message: String
    let recipientUid: String
    let showId: String
    let showName: String
    let bandId: String

    init(
        id: String,
        recipientFcmToken: String?,
        senderFcmToken: String?,
        notificationType: String = NotificationType.showApplication.rawValue,
        bandName: String,
        message: String,
        recipientUid: String,
        showId: String,
        showName: String,
        bandId: String
    ) {
        self.id = id
        self.recipientFcmToken = recipientFcmToken
        self.senderFcmToken = senderFcmToken
        self.notificationType = notificationType
        self.bandName = bandName
        self.message = message
        self.recipientUid = recipientUid
        self.showId = showId
        self.showName = showName
        self.bandId = bandId
    }
}
