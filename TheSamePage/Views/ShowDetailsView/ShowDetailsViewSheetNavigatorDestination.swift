//
//  ShowDetailsViewSheetNavigatorDestination.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/19/23.
//

import Foundation

enum ShowDetailsViewSheetNavigatorDestination {
    case none
    case showSettingsView(show: Show)
    case conversationView(show: Show, chatParticipantUids: [String])
    case showApplicationView(show: Show)
}
