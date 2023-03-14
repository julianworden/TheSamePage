//
//  AppOpenedViaNotificationSheetNavigatorViewDestination.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/12/23.
//

import Foundation

enum AppOpenedViaNotificationSheetNavigatorViewDestination {
    case none
    case conversationView(chatId: String)
    case showDetailsView(showId: String)
    case otherUserProfileView(uid: String)
    case bandProfileView(bandId: String)
}
