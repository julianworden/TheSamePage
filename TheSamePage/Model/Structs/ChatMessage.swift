//
//  ChatMessage.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import FirebaseFirestoreSwift
import Foundation

struct ChatMessage: Codable, Equatable, Identifiable {
    // TODO: Add a chatId property that shows which chat this message is a part of
    // Leaving this as an @DocumentID property to avoid doubling write amount
    // every time a message is sent
    @DocumentID var id: String?
    let text: String
    let senderUid: String
    let chatId: String
    let senderFullName: String
    let sentTimestamp: Double
    var recipientFcmTokens: [String] = []
    
    var senderIsLoggedInUser: Bool {
        return senderUid == AuthController.getLoggedInUid()
    }

    static let example = ChatMessage(
        text: "Hello, how is everyone?",
        senderUid: "a;weifawhj;lefahjwef",
        chatId: "a;sldfja;sldkj",
        senderFullName: "Julian Worden",
        sentTimestamp: 3636363636,
        recipientFcmTokens: ["a;slkdfja;sldf", "al;wifhwurte"]
    )
}
