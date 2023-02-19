//
//  AnyUserNotification.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/12/22.
//

import Foundation

/// A wrapper type that makes it possible to use a type conforming to the UserNotification protocol
/// in conjunction with a SwiftUI list.
struct AnyUserNotification: Identifiable {
    let id: String
    let notification: any UserNotification
    
    var notificationType: NotificationType {
        let notificationTypeAsString = notification.notificationType
        return NotificationType(rawValue: notificationTypeAsString)!
    }
    
    var notificationTitle: String {
        switch notificationType {
        case .showInvite:
            return "Show Invite"
        case .bandInvite:
            return "Band Invite"
        case .showApplication:
            return "Show Application"
        }
    }
    
    var iconName: String {
        switch notificationType {
        case .bandInvite:
            return "person.3"
        case .showInvite:
            return "music.note.house"
        case .showApplication:
            return "rectangle.and.pencil.and.ellipsis"
        }
    }
}
