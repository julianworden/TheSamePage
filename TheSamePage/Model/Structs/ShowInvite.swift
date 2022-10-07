//
//  ShowInvite.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct ShowInvite: Codable, Equatable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var dateSent: Timestamp?
    let recipientUid: String
    let bandName: String
    let bandId: String
    let showId: String
    let showName: String
    let senderUsername: String
    
    var inviteMessage: String {
        return "\(senderUsername) is inviting \(bandName) to play \(showName)"
    }
    
    static let example = ShowInvite(
        recipientUid: ";askldjf;alskdjf",
        bandName: "Pathetic Fallacy",
        bandId: "a;lsdkjfa;lsdjf",
        showId: "asdkfa;wefj",
        showName: "Banger",
        senderUsername: "ericpalermo"
    )
}
