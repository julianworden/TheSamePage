//
//  UserNotification.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/12/22.
//

import Foundation

protocol UserNotification: Codable, Equatable, Hashable, Identifiable {
    var id: String { get }
    var recipientFcmToken: String? { get }
    var notificationType: String { get }
    var message: String { get }
    var recipientUid: String { get }
    var acceptanceMessage: String { get }
    var sentTimestamp: Double { get }
    var senderUid: String { get }
}
