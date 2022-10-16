//
//  SendShowInviteViewState.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/14/22.
//

import Foundation

enum ViewState {
    case dataLoading
    case dataLoaded
    case dataNotFound
    case error(message: String)
}
