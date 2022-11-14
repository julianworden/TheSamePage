//
//  Invite.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct BandInvite: Codable, Equatable, Hashable, Identifiable, UserNotification {
    @DocumentID var id: String?
    @ServerTimestamp var dateSent: Timestamp?
    let notificationType: String
    let recipientUid: String
    let recipientRole: String
    let bandId: String
    let senderUsername: String
    let senderBand: String
    let message: String
    
    var inviteMessage: String {
        return "\(senderUsername) is inviting you to join \(senderBand)"
    }
    
    static var example = BandInvite(
        notificationType: NotificationType.bandInvite.rawValue,
        recipientUid: "as;ldkfjapwoiefhaw;jgr",
        recipientRole: "Guitar",
        bandId: "aposiefjawpefhaw;jgn",
        senderUsername: "ericpalermo",
        senderBand: "Dumpweed",
        message: "ericpalermo is inviting you to join Dumpweed"
    )
}
