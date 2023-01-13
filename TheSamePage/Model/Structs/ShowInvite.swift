//
//  ShowInvite.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct ShowInvite: Codable, Equatable, Identifiable, UserNotification {
    var id: String
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
}
