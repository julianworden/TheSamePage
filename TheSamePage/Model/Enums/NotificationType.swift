//
//  NotificationType.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/6/22.
//

import Foundation

enum NotificationType: String, CaseIterable, Codable, Identifiable {
    case bandInvite = "Band Invite"
    case showInvite = "Show Invite"
    case showApplication = "Show Application"
    
    var id: Self { self }
}
