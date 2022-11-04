//
//  ConversationViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/3/22.
//

import Foundation

class ConversationViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages = [ChatMessage]()
    
    let show: Show?
    let userId: String?
    var chat: Chat?
    
    init(show: Show? = nil, userId: String? = nil) {
        self.show = show
        self.userId = userId
    }
    
    func configureChat() async {
        if let show {
            do {
                if let fetchedChat = try await DatabaseService.shared.getChat(withShowId: show.id) {
                    Task { @MainActor in
                        messages = try await DatabaseService.shared.getMessagesForChat(chat: fetchedChat)
                    }
                } else {
                    var chatParticipants = show.participantUids
                    if !show.participantUids.contains(show.hostUid) {
                        chatParticipants.append(show.hostUid)
                    }
                    let newChat = Chat(id: "", showId: show.id, name: show.name, participantUids: chatParticipants)
                    try await DatabaseService.shared.createChat(chat: newChat)
                }
            } catch {
                // TODO: Alter state
            }
        }
    }
}
