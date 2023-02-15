//
//  Invite.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct BandInvite: UserNotification {
    var id: String
    var recipientFcmToken: String?
    var recipientUsername: String
    var senderFcmToken: String?
    let sentTimestamp: Double
    let notificationType: String
    var recipientUid: String
    let recipientRole: String
    let bandId: String
    let senderUsername: String
    let senderBand: String
    let message: String
    
    static var example = BandInvite(
        id: "aowiefawpoefijaw;ef",
        recipientFcmToken: "a;lskdfa;sklfj",
        recipientUsername: "julianworden",
        senderFcmToken: "qweryqwouieh",
        sentTimestamp: Date.now.timeIntervalSince1970,
        notificationType: NotificationType.bandInvite.rawValue,
        recipientUid: "as;ldkfjapwoiefhaw;jgr",
        recipientRole: "Guitar",
        bandId: "aposiefjawpefhaw;jgn",
        senderUsername: "ericpalermo",
        senderBand: "Dumpweed",
        message: "ericpalermo is inviting you to join Dumpweed"
    )

    var acceptanceMessage: String {
        return "\(recipientUsername) is now a member of \(senderBand)."
    }
}
