//
//  Invite.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct BandInvite: Codable, Equatable, Hashable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var dateSent: Timestamp?
    let recipientUid: String
    let recipientRole: String
    let bandId: String
    let senderName: String
    let senderBand: String
    
    var inviteMessage: String {
        return "\(senderName) is inviting you to join \(senderBand)"
    }
    
    static var example = BandInvite(
        recipientUid: "as;ldkfjapwoiefhaw;jgr",
        recipientRole: "Guitar",
        bandId: "aposiefjawpefhaw;jgn",
        senderName: "ericpalermo",
        senderBand: "Dumpweed"
    )
}
