//
//  Chat.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import Foundation

struct Chat: Codable, Equatable, Hashable, Identifiable {
    var id: String
    let type: String
    /// The ID of the show that the chat belongs to.
    let showId: String?
    let name: String?
    let participantUids: [String]
    let participantUsernames: [String]
    let currentViewerUids: [String]
    let mostRecentMessageText: String?
    let mostRecentMessageTimestamp: Double?
    let mostRecentMessageSenderUsername: String?
    /// The UIDs for the users that have seen the latest message in the chat.
    let upToDateParticipantUids: [String]

    init(
        id: String,
        type: String,
        showId: String? = nil,
        name: String? = nil,
        participantUids: [String],
        participantUsernames: [String],
        currentViewerUids: [String] = [],
        mostRecentMessageText: String? = nil,
        mostRecentMessageTimestamp: Double? = nil,
        mostRecentMessageSenderUsername: String? = nil,
        upToDateParticipantUids: [String] = []
    ) {
        self.id = id
        self.type = type
        self.showId = showId
        self.name = name
        self.participantUids = participantUids
        self.participantUsernames = participantUsernames
        self.currentViewerUids = currentViewerUids
        self.mostRecentMessageText = mostRecentMessageText
        self.mostRecentMessageTimestamp = mostRecentMessageTimestamp
        self.mostRecentMessageSenderUsername = mostRecentMessageSenderUsername
        self.upToDateParticipantUids = upToDateParticipantUids
    }
    
    /// A convenience property for filtering the logged in user's UID out of the
    /// participantUids array. This will make it easier to refer to the chat's
    /// participants without also referring to the logged in user.
    var participantUidsWithoutLoggedInUser: [String] {
        return participantUids.filter { $0 != AuthController.getLoggedInUid() }
    }

    var participantUsernamesWithoutLoggedInUser: [String] {
        return participantUsernames.filter { $0 != AuthController.getLoggedInUsername() }
    }

    var mostRecentMessageSenderUsernameDescription: String {
        if mostRecentMessageSenderUsername == AuthController.getLoggedInUsername() {
            return "You:"
        } else if let mostRecentMessageSenderUsername {
            return "\(mostRecentMessageSenderUsername):"
        } else {
            return ""
        }
    }

    var loggedInUserIsUpToDate: Bool {
        upToDateParticipantUids.contains(AuthController.getLoggedInUid())
    }
}
