//
//  UserNotification.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/12/22.
//

import Foundation

protocol UserNotification {
    var notificationType: String { get }
    var senderUsername: String { get }
    var message: String { get }
    var recipientUid: String { get }
}
