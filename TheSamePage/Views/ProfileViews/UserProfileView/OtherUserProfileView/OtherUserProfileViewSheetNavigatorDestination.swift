//
//  OtherUserProfileViewSheetNavigatorDestination.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/21/23.
//

import Foundation

enum OtherUserProfileViewSheetNavigatorDestination {
    case conversationView(chatParticipantUids: [String])
    case sendBandInvite(user: User)
    case none
}
