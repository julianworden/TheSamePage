//
//  ChatMessage.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import FirebaseFirestoreSwift
import Foundation

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let text: String
    let senderUid: String
    let senderFullName: String
    let sentTimestamp: Double
    let recipientFcmTokens: [String]
    
    static let example = ChatMessage(
        text: "Hello, how is everyone?",
        senderUid: "a;weifawhj;lefahjwef",
        senderFullName: "Julian Worden",
        sentTimestamp: 3636363636,
        recipientFcmTokens: ["a;slkdfja;sldf", "al;wifhwurte"]
    )
    
    var senderIsLoggedInUser: Bool {
        return senderUid == AuthController.getLoggedInUid()
    }
    
    var sentUnixDateAsDate: Date {
        return Date(timeIntervalSince1970: sentTimestamp)
    }
}
