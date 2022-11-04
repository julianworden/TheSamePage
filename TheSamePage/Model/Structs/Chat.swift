//
//  Chat.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import Foundation

struct Chat: Codable, Identifiable {
    var id: String
    /// The ID of the show that the chat belongs to. This is optional because it will
    /// make it easier to add chatting for all users at a later time.
    let showId: String?
    let userId: String?
    let name: String?
    let participantUids: [String]
    
    init(id: String, showId: String? = nil, userId: String? = nil, name: String? = nil, participantUids: [String]) {
        self.id = id
        self.showId = showId
        self.userId = userId
        self.name = name
        self.participantUids = participantUids
    }
}
