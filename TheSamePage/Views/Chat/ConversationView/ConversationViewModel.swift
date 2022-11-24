//
//  ConversationViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/3/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

@MainActor
class ConversationViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages = [ChatMessage]()
    @Published var showParticipants = [ShowParticipant]()
    
    @Published var sendButtonIsDisabled = true
    @Published var errorAlertIsShowing = false
    @Published var errorAlertText = ""
    
    @Published var viewState = ViewState.dataLoaded {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                print("Unknown viewState set in ConversationViewModel")
            }
        }
    }
    
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
    
    func callOnAppearMethods() async {
        await configureChat()
        addChatListener()
    }
    
    func addChatListener() {
        guard let chat else { return } // TODO: Change state in this guard's else block
        
        chatMessagesListener = db
            .collection(FbConstants.chats)
            .document(chat.id)
            .collection(FbConstants.messages)
            .addSnapshotListener { snapshot, error in
                if let snapshot, error == nil {
                    guard !snapshot.documents.isEmpty else { return }
                    
                    let chatMessageDocuments = snapshot.documents
                    
                    if let chatMessages = try? chatMessageDocuments.map({ try $0.data(as: ChatMessage.self) }) {
                        let sortedChatMessages = chatMessages.sorted { $0.sentTimestampAsDate < $1.sentTimestampAsDate }
                        self.messages = sortedChatMessages
                    } else {
                        self.viewState = .error(message: "Failed to fetch up-to-date chat messages. Please relaunch The Same Page and try again.")
                    }
                } else if error != nil {
                    self.viewState = .error(message: error!.localizedDescription)
                }
            }
    }
    
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
                viewState = .error(message: error.localizedDescription)
            }
        }
    }
    
    func sendMessageButtonTapped(by user: User?) async {
        await sendChatMessage(fromUser: user)
        messageText = ""
    }
    
    func sendChatMessage(fromUser user: User?) async {
        guard let chat,
              let user,
              !messageText.isEmpty else { return }
        
        do {
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
            // TODO: Figure out why this state isn't being changed when wifi is off
            viewState = .error(message: error.localizedDescription)
        }
    }
}
