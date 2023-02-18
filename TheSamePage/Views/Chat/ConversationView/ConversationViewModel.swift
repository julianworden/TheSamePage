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
class ConversationViewModel : ObservableObject {
    @Published var messageText = ""
    @Published var messages = [ChatMessage]()
    @Published var chatParticipantUids = [String]()
    
    @Published var sendButtonIsDisabled = true
    @Published var errorAlertIsShowing = false
    @Published var errorAlertText = ""
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                if viewState != .dataLoaded {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }
    
    var show: Show?
    let userId: String?
    var chat: Chat?
    var chatId: String?
    
    var chatMessagesListener: ListenerRegistration?
    let db = Firestore.firestore()
    
    init(chatId: String? = nil, show: Show? = nil, userId: String? = nil, chatParticipantUids: [String] = []) {
        self.show = show
        self.userId = userId
        self.chatParticipantUids = chatParticipantUids

            Task {
                if let chatId {
                    let chat = try await DatabaseService.shared.getChat(withId: chatId)
                    self.show = try await DatabaseService.shared.getShow(showId: chat.showId ?? "")
                    self.chat = chat
                    self.chatParticipantUids = chat.participantUids
                    await callOnAppearMethods()
                }
            }
        }
    
    func callOnAppearMethods() async {
        if let show {
            _ = await configureShowChat(forShow: show)
        }

        if let chat {
            addChatListener(forChat: chat)
        }
    }

    func addChatListener(forChat chat: Chat) {
        chatMessagesListener = db
            .collection(FbConstants.chats)
            .document(chat.id)
            .collection(FbConstants.messages)
            .order(by: FbConstants.sentTimestamp, descending: true)
            .limit(to: 20)
            .addSnapshotListener { snapshot, error in
                if let snapshot, error == nil {
                    guard !snapshot.documents.isEmpty else { return }

                    let chatMessageDocuments = snapshot.documents
                    
                    if let chatMessages = try? chatMessageDocuments.map({ try $0.data(as: ChatMessage.self) }) {
                        self.messages = chatMessages.reversed()
                    } else {
                        self.viewState = .error(message: "Failed to fetch up-to-date chat messages. Please relaunch The Same Page and try again.")
                    }
                } else if error != nil {
                    self.viewState = .error(message: error!.localizedDescription)
                }
            }

        viewState = .dataLoaded
    }

    func getMoreMessages(before timestamp: Double) async {
        do {
            let nextTwentyMessages = try await DatabaseService.shared.getMessagesForChat(chat: chat!, before: timestamp)
            nextTwentyMessages.forEach {
                messages.insert($0, at: 0)
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func configureShowChat(forShow show: Show) async -> String? {
        do {
            if try await DatabaseService.shared.chatExists(forShowWithId: show.id) {
                let fetchedChat = try await DatabaseService.shared.getChat(withShowId: show.id)
                self.chat = fetchedChat
                return fetchedChat?.id
            } else {
                var chatParticipantUids = show.participantUids
                if !show.participantUids.contains(show.hostUid) {
                    chatParticipantUids.append(show.hostUid)
                }
                var newChat = Chat(
                    id: "",
                    showId: show.id,
                    name: show.name,
                    participantUids: chatParticipantUids
                )
                let newChatId = try await DatabaseService.shared.createChat(chat: newChat)
                newChat.id = newChatId
                self.chat = newChat
                return newChatId
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }
    
    func sendMessageButtonTapped(by user: User?) async {
        await sendChatMessage(fromUser: user)
        messageText = ""
    }
    
    func sendChatMessage(fromUser user: User?) async {
        guard let chat,
              let user else {
            viewState = .error(
                message: LogicError.unexpectedNilValue(message: "Failed to send chat message. Please relaunch The Same Page and try again").localizedDescription)
            return
        }

        guard !messageText.isReallyEmpty else {
            viewState = .error(message: LogicError.emptyChatMessage.localizedDescription)
            return
        }
        
        do {
            let senderUid = user.id
            let senderFullName = user.fullName
            var recipientFcmTokens = [String]()

            for uid in chat.participantUidsWithoutLoggedInUser {
                if let recipientFcmToken = try await DatabaseService.shared.getFcmToken(forUserWithUid: uid) {
                    recipientFcmTokens.append(recipientFcmToken)
                }
            }

            let newChatMessage = ChatMessage(
                text: messageText,
                senderUid: senderUid,
                chatId: chat.id,
                senderFullName: senderFullName,
                sentTimestamp: Date().timeIntervalSince1970,
                recipientFcmTokens: recipientFcmTokens
            )
            
            try DatabaseService.shared.sendChatMessage(chatMessage: newChatMessage, chat: chat)
        } catch {
            // TODO: Figure out why this state isn't being changed when wifi is off
            viewState = .error(message: error.localizedDescription)
        }
    }

    func removeChatListener() {
        chatMessagesListener?.remove()
    }
}
