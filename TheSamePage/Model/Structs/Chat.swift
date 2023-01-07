//
//  Chat.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import Foundation

struct Chat: Codable, Equatable, Identifiable {
    var id: String
    /// The ID of the show that the chat belongs to. This is optional because it will
    /// make it easier to add chatting for all users at a later time.
    let showId: String?
    let userId: String?
    let name: String?
    let participantUids: [String]
    let participantFcmTokens: [String]
    
    init(
        id: String,
        showId: String? = nil,
        userId: String? = nil,
        name: String? = nil,
        participantUids: [String],
        participantFcmTokens: [String] = []
    ) {
        self.id = id
        self.showId = showId
        self.userId = userId
        self.name = name
        self.participantUids = participantUids
        self.participantFcmTokens = participantFcmTokens
    }
    
    /// A convenience property for filtering the logged in user's UID out of the
    /// participantUids array. This will make it easier to refer to the chat's
    /// participants without also referring to the logged in user.
    var participantUidsWithoutLoggedInUser: [String] {
        var filteredParticipantUids = [String]()
        filteredParticipantUids = participantUids.filter { $0 != AuthController.getLoggedInUid() }
        return filteredParticipantUids
    }
}
