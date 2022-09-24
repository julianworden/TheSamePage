//
//  Invite.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct BandInvite: Codable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var dateSent: Timestamp?
    let recipientUid: String
    let bandId: String
    let senderName: String
    let senderBand: String
    
    static var example = BandInvite(
        recipientUid: "as;ldkfjapwoiefhaw;jgr",
        bandId: "aposiefjawpefhaw;jgn",
        senderName: "ericpalermo",
        senderBand: "Dumpweed"
    )
}
