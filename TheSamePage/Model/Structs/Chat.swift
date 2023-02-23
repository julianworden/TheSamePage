//
//  Chat.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import Foundation

struct Chat: Codable, Equatable, Hashable, Identifiable {
    var id: String
    /// The ID of the show that the chat belongs to. This is optional because it will
    /// make it easier to add chatting for all users at a later time.
    let showId: String?
    let userId: String?
    let name: String?
    let participantUids: [String]
    let currentViewerUids: [String]
    let mostRecentMessageText: String?
    let mostRecentMessageTimestamp: Double?
    /// The UIDs for the users that have seen the latest message in the chat.
    let upToDateParticipantUids: [String]

    init(
        id: String,
        showId: String? = nil,
        userId: String? = nil,
        name: String? = nil,
        participantUids: [String],
        currentViewerUids: [String] = [],
        mostRecentMessageText: String? = nil,
        mostRecentMessageTimestamp: Double? = nil,
        upToDateParticipantUids: [String] = []
    ) {
        self.id = id
        self.showId = showId
        self.userId = userId
        self.name = name
        self.participantUids = participantUids
        self.currentViewerUids = currentViewerUids
        self.mostRecentMessageText = mostRecentMessageText
        self.mostRecentMessageTimestamp = mostRecentMessageTimestamp
        self.upToDateParticipantUids = upToDateParticipantUids
    }
    
    /// A convenience property for filtering the logged in user's UID out of the
    /// participantUids array. This will make it easier to refer to the chat's
    /// participants without also referring to the logged in user.
    var participantUidsWithoutLoggedInUser: [String] {
        var filteredParticipantUids = [String]()
        filteredParticipantUids = participantUids.filter { $0 != AuthController.getLoggedInUid() }
        return filteredParticipantUids
    }

    var loggedInUserIsUpToDate: Bool {
        upToDateParticipantUids.contains(AuthController.getLoggedInUid())
    }
}
