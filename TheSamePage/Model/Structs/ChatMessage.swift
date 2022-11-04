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
}
