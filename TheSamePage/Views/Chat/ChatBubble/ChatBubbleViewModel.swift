//
//  ChatBubbleViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/4/22.
//

import Foundation

#warning("Get rid of this viewmodel")
class ChatBubbleViewModel: ObservableObject {
    let chatMessage: ChatMessage

    init(chatMessage: ChatMessage) {
        self.chatMessage = chatMessage
    }
}
