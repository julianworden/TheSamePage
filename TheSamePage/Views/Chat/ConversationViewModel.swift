//
//  ConversationViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/3/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class ConversationViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages = [ChatMessage]()
    
    let show: Show?
    let userId: String?
    var chat: Chat?
    
    var chatMessagesListener: ListenerRegistration?
    let db = Firestore.firestore()
    
    init(show: Show? = nil, userId: String? = nil) {
        self.show = show
        self.userId = userId
    }
    
    func addChatListener() {
        guard let chat else { return } // TODO: Change state in this guard's else block
        
        chatMessagesListener = db.collection("chats").document(chat.id).collection("messages").addSnapshotListener { snapshot, error in
            if let snapshot, error == nil, !snapshot.documents.isEmpty {
                let chatMessageDocuments = snapshot.documents
                if let chatMessages = try? chatMessageDocuments.map({ try $0.data(as: ChatMessage.self) }) {
                    Task { @MainActor in
                        let sortedChatMessages = chatMessages.sorted { lhs, rhs in
                            lhs.sentTimestampAsDate < rhs.sentTimestampAsDate
                        }
                        self.messages = sortedChatMessages
                    }
                } else {
                    // TODO: Change state
                }
            } else {
                // TODO: Change state
            }
        }
    }
    
    @MainActor
    func configureChat() async {
        if let show {
            do {
                if let fetchedChat = try await DatabaseService.shared.getChat(withShowId: show.id) {
                    self.chat = fetchedChat
                    messages = try await DatabaseService.shared.getMessagesForChat(chat: fetchedChat)
                } else {
                    var chatParticipants = show.participantUids
                    if !show.participantUids.contains(show.hostUid) {
                        chatParticipants.append(show.hostUid)
                    }
                    var newChat = Chat(id: "", showId: show.id, name: show.name, participantUids: chatParticipants)
                    let newChatId = try await DatabaseService.shared.createChat(chat: newChat)
                    newChat.id = newChatId
                    self.chat = newChat
                }
            } catch {
                // TODO: Alter state
            }
        }
    }
    
    func sendChatMessage() async {
        guard let chat, !messageText.isEmpty else { return }
        
        do {
            let senderUid = AuthController.getLoggedInUid()
            let senderFullName = try await AuthController.getLoggedInFullName()
            
            let newChatMessage = ChatMessage(text: messageText, senderUid: senderUid, senderFullName: senderFullName, sentTimestamp: Date().timeIntervalSince1970)
            try DatabaseService.shared.sendChatMessage(chatMessage: newChatMessage, chat: chat)
        } catch {
            // TODO: Change state
        }
    }
}
