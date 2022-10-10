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
    let showDate: String
    let showVenue: String
    var showDescription: String?
    let senderUsername: String
    let hasFood: Bool
    let hasBar: Bool
    let is21Plus: Bool
    
    var inviteMessage: String {
        return "\(senderUsername) is inviting \(bandName) to play \(showName) at \(showVenue) on \(showDate)"
    }
    
    static let example = ShowInvite(
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
        is21Plus: true
    )
}
