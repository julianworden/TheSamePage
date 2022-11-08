//
//  ChatInfoViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/7/22.
//

import Foundation

class ChatInfoViewModel: ObservableObject {
    @Published var chatParticipants = [ShowParticipant]()
    
    init(chatParticipants: [ShowParticipant]) {
        self.chatParticipants = chatParticipants
    }
}
