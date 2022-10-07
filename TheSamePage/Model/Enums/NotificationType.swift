//
//  NotificationType.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/6/22.
//

import Foundation

enum NotificationType: String, CaseIterable, Identifiable {
    case bandInvite = "Band Invites"
    case showInvite = "Show Invites"
    
    var id: Self { self }
}
