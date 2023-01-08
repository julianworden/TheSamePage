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
    @DocumentID var id: String?
    @ServerTimestamp var dateSent: Timestamp?
    let notificationType: String
    let recipientUid: String
    let bandName: String
    let bandId: String
    let showId: String
    let showName: String
    let showDate: String
    let showVenue: String
    var showDescription: String?
    let senderUsername: String
    let hasFood: Bool
    let hasBar: Bool
    let is21Plus: Bool
    let message: String
    
    static let example = ShowInvite(
        notificationType: NotificationType.showInvite.rawValue,
        recipientUid: ";askldjf;alskdjf",
        bandName: "Pathetic Fallacy",
        bandId: "a;lsdkjfa;lsdjf",
        showId: "asdkfa;wefj",
        showName: "Banger",
        showDate: "03/22/22",
        showVenue: "Starland Ballroom",
        showDescription: "This one is gonna be so sick!",
        senderUsername: "ericpalermo",
        hasFood: true,
        hasBar: true,
        is21Plus: true,
        message: "ericpalermo is inviting Pathetic Fallacy to play Absolute Banger at Starland Ballroom on 10/11/22"
    )
}
