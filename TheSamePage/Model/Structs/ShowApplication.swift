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
    let sentTimestamp: Double
    let notificationType: String
    let bandName: String
    let message: String
    var senderUid: String
    let recipientUid: String
    let showId: String
    let showName: String
    let bandId: String

    init(
        id: String,
        recipientFcmToken: String?,
        sentTimestamp: Double,
        notificationType: String = NotificationType.showApplication.rawValue,
        bandName: String,
        message: String,
        recipientUid: String,
        senderUid: String,
        showId: String,
        showName: String,
        bandId: String
    ) {
        self.id = id
        self.recipientFcmToken = recipientFcmToken
        self.sentTimestamp = sentTimestamp
        self.notificationType = notificationType
        self.bandName = bandName
        self.message = message
        self.recipientUid = recipientUid
        self.showId = showId
        self.showName = showName
        self.bandId = bandId
        self.senderUid = senderUid
    }

    var acceptanceMessage: String {
        return "\(bandName) is now playing \(showName)."
    }
}
