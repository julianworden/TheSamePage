//
//  ShowInvite.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct ShowInvite: UserNotification {
    var id: String
    var recipientFcmToken: String?
    var senderFcmToken: String?
    var dateSent: Double
    let notificationType: String
    let recipientUid: String
    let bandName: String
    var bandId: String
    let showId: String
    let showName: String
    let showDate: Double
    let showVenue: String
    var showDescription: String?
    let senderUsername: String
    let hasFood: Bool
    let hasBar: Bool
    let is21Plus: Bool
    let message: String
    
    static let example = ShowInvite(
        id: "a;slkdfja;lsdjf",
        recipientFcmToken: "a;lskdfa;sklfj",
        senderFcmToken: "ertupwqeritnb",
        dateSent: 123232,
        notificationType: NotificationType.showInvite.rawValue,
        recipientUid: ";askldjf;alskdjf",
        bandName: "Pathetic Fallacy",
        bandId: "a;lsdkjfa;lsdjf",
        showId: "asdkfa;wefj",
        showName: "Banger",
        showDate: 223123,
        showVenue: "Starland Ballroom",
        showDescription: "This one is gonna be so sick!",
        senderUsername: "ericpalermo",
        hasFood: true,
        hasBar: true,
        is21Plus: true,
        message: "ericpalermo is inviting Pathetic Fallacy to play Absolute Banger at Starland Ballroom on 10/11/22"
    )

    #warning("TEST")
    var acceptanceMessage: String {
        return "\(bandName) is now playing \(showName)."
    }
}
