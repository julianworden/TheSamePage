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
    @Published var showParticipants = [ShowParticipant]()
    
    let show: Show?
    let userId: String?
    var chat: Chat?
    
    var chatMessagesListener: ListenerRegistration?
    let db = Firestore.firestore()
    
    init(show: Show? = nil, userId: String? = nil, showParticipants: [ShowParticipant]) {
        self.show = show
        self.userId = userId
        self.showParticipants = showParticipants
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
                    var chatParticipantUids = show.participantUids
                    if !show.participantUids.contains(show.hostUid) {
                        chatParticipantUids.append(show.hostUid)
                    }
                    let chatParticipantFcmTokens = try await DatabaseService.shared.getChatFcmTokens(withUids: chatParticipantUids)
                    var newChat = Chat(id: "", showId: show.id, name: show.name, participantUids: chatParticipantUids, participantFcmTokens: chatParticipantFcmTokens)
                    let newChatId = try await DatabaseService.shared.createChat(chat: newChat)
                    newChat.id = newChatId
                    self.chat = newChat
                }
            } catch {
                // TODO: Alter state
            }
        }
    }
    
    func sendChatMessage(fromUser user: User?) async {
        guard let chat,
              let user,
              !messageText.isEmpty else { return }
        
        do {
            // TODO: GET THE USER OBJECT
            let senderUid = user.id
            let senderFullName = user.fullName
            let senderFcmToken = user.fcmToken
            
            let filteredFcmTokens = chat.participantFcmTokens.filter { $0 != senderFcmToken }
            
            let newChatMessage = ChatMessage(
                text: messageText,
                senderUid: senderUid,
                senderFullName: senderFullName,
                sentTimestamp: Date().timeIntervalSince1970,
                recipientFcmTokens: filteredFcmTokens
            )
            try DatabaseService.shared.sendChatMessage(chatMessage: newChatMessage, chat: chat)
        } catch {
            // TODO: Change state
        }
    }
}
