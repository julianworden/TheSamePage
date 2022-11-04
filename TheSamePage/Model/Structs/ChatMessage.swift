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
    
    static let example = ChatMessage(text: "Hello, how is everyone?", senderUid: "a;weifawhj;lefahjwef", senderFullName: "Julian Worden", sentTimestamp: 3636363636)
    
    var senderIsLoggedInUser: Bool {
        return senderUid == AuthController.getLoggedInUid()
    }
    
    var sentTimestampAsDate: Date {
        return Date(timeIntervalSince1970: sentTimestamp)
    }
}