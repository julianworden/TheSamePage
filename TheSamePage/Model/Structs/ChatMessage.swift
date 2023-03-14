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
    let chatName: String?
    let chatType: String
    let senderFullName: String
    let senderUsername: String
    let sentTimestamp: Double
    var recipientFcmTokens: [String] = []
    // Add recipientUids property
    
    var senderIsLoggedInUser: Bool {
        return senderUid == AuthController.getLoggedInUid()
    }

    static let example = ChatMessage(
        text: "Hello, how is everyone?",
        senderUid: "a;weifawhj;lefahjwef",
        chatId: "a;sldfja;sldkj",
        chatName: "Sick Chat",
        chatType: ChatType.oneOnOne.rawValue,
        senderFullName: "Julian Worden",
        senderUsername: "julianworden",
        sentTimestamp: 3636363636,
        recipientFcmTokens: ["a;slkdfja;sldf", "al;wifhwurte"]
    )
}
