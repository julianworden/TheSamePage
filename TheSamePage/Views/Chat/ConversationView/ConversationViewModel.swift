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
    @Published var textFieldIsDisabled = false
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
    var isPresentedModally: Bool
    
    var chatMessagesListener: ListenerRegistration?
    let db = Firestore.firestore()

    var navigationTitle: String {
        if let show {
            return show.name
        } else {
            return "Chat"
        }
    }
    
    init(chat: Chat?, chatId: String? = nil, show: Show? = nil, userId: String? = nil, chatParticipantUids: [String] = [], isPresentedModally: Bool = false) {
        self.chat = chat
        self.show = show
        self.userId = userId
        self.chatParticipantUids = chatParticipantUids
        self.isPresentedModally = isPresentedModally
        self.chatId = chatId
    }
    
    func callOnAppearMethods() async {
        if let show {
            _ = await configureShowChat(forShow: show)
        } else if let chat {
            await configureExistingChat(chat)
        } else if let chatId {
            _ = await configureChatWithId(chatId)
        } else {
            _ = await configureChatWithParticipantUids(chatParticipantUids)
        }
    }

    func addChatMessagesListener(forChat chat: Chat) {
        chatMessagesListener = db
            .collection(FbConstants.chats)
            .document(chat.id)
            .collection(FbConstants.messages)
            .order(by: FbConstants.sentTimestamp, descending: true)
            .limit(to: 20)
            .addSnapshotListener { snapshot, error in
                if let snapshot, error == nil {
                    guard !snapshot.documents.isEmpty else {
                        self.viewState = .dataLoaded
                        return
                    }

                    let chatMessageDocuments = snapshot.documents
                    
                    if let chatMessages = try? chatMessageDocuments.map({ try $0.data(as: ChatMessage.self) }) {
                        self.messages = chatMessages.reversed()
                        self.viewState = .dataLoaded
                    } else {
                        self.viewState = .error(message: "Failed to fetch up-to-date chat messages. Please relaunch The Same Page and try again.")
                    }
                } else if error != nil {
                    self.viewState = .error(message: error!.localizedDescription)
                }
            }
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

    func configureExistingChat(_ chat: Chat) async {
        addChatMessagesListener(forChat: chat)
        await addUserToChatUpToDateParticipantUids(chat: chat)
        if !EnvironmentVariableConstants.unitTestsAreRunning {
            await addChatViewer()
        }
    }

    func configureChatWithId(_ chatId: String) async {
        do {
            let chat = try await DatabaseService.shared.getChat(withId: chatId)
            self.chat = chat
            self.chatParticipantUids = chat.participantUids
            if let chatShowId = chat.showId {
                self.show = try await DatabaseService.shared.getShow(showId: chatShowId)
            }
            await configureExistingChat(chat)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func configureChatWithParticipantUids(_ participantUids: [String]) async {
        do {
            if let fetchedChat = try await DatabaseService.shared.getChat(ofType: .oneOnOne, withParticipantUids: participantUids) {
                self.chat = fetchedChat
                await configureExistingChat(fetchedChat)
            } else {
                viewState = .dataLoaded
            }
        } catch FirebaseError.dataNotFound {
            viewState = .dataLoaded
        } catch {
            print(error)
            viewState = .error(message: error.localizedDescription)
        }
    }
    
    func configureShowChat(forShow show: Show) async -> String? {
        do {
            if let showChat = try await DatabaseService.shared.getChat(withShowId: show.id) {
                self.chat = showChat
                await configureExistingChat(showChat)
                return showChat.id
            } else {
                return await createNewShowChat(forShow: show)
            }
        } catch FirebaseError.dataNotFound {
            viewState = .dataLoaded
            return nil
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }

    func createNewShowChat(forShow show: Show) async -> String? {
        do {
            var chatParticipantUids = show.participantUids
            if !show.participantUids.contains(show.hostUid) {
                chatParticipantUids.append(show.hostUid)
            }
            var newChatParticipantUsernames = [String]()
            for uid in chatParticipantUids {
                let user = try await DatabaseService.shared.getUser(withUid: uid)
                newChatParticipantUsernames.append(user.name)
            }
            var newChat = Chat(
                id: "",
                type: ChatType.show.rawValue,
                showId: show.id,
                name: show.name,
                participantUids: chatParticipantUids,
                participantUsernames: newChatParticipantUsernames
            )
            let newChatId = try await DatabaseService.shared.createChat(chat: newChat)
            newChat.id = newChatId
            self.chat = newChat
            await configureExistingChat(newChat)
            return newChatId
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }
    
    @discardableResult func sendMessageButtonTapped(by user: User?) async -> ChatMessage? {
        do {
            textFieldIsDisabled = true

            if chat != nil {
                let newChatMessage = await sendChatMessage(fromUser: user)
                textFieldIsDisabled = false
                return newChatMessage
            } else {
                var newChatParticipantUsernames = [String]()
                for uid in chatParticipantUids {
                    let user = try await DatabaseService.shared.getUser(withUid: uid)
                    newChatParticipantUsernames.append(user.name)
                }

                var newChat = Chat(
                    id: "",
                    type: ChatType.oneOnOne.rawValue,
                    participantUids: chatParticipantUids,
                    participantUsernames: newChatParticipantUsernames
                )
                let newChatId = try await DatabaseService.shared.createChat(chat: newChat)
                newChat.id = newChatId
                self.chat = newChat
                await configureExistingChat(newChat)

                let newChatMessage = await sendChatMessage(fromUser: user)
                textFieldIsDisabled = false
                return newChatMessage
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
            textFieldIsDisabled = false
            return nil
        }
    }
    
    func sendChatMessage(fromUser user: User?) async -> ChatMessage? {
        guard let chat,
              let user else {
            viewState = .error(
                message: "Failed to send chat message. Please relaunch The Same Page and try again.")
            return nil
        }

        guard !messageText.isReallyEmpty else {
            viewState = .error(message: LogicError.emptyChatMessage.localizedDescription)
            return nil
        }

        let preservedMessageText = messageText
        messageText = ""
        
        do {
            var recipientFcmTokens = [String]()
            let upToDateChat = try await DatabaseService.shared.getChat(withId: chat.id)

            for uid in chat.participantUidsWithoutLoggedInUser {
                if !upToDateChat.currentViewerUids.contains(uid),
                   let recipientFcmToken = try await DatabaseService.shared.getFcmToken(forUserWithUid: uid) {
                    recipientFcmTokens.append(recipientFcmToken)
                }
            }

            let newChatMessage = ChatMessage(
                text: preservedMessageText,
                senderUid: user.id,
                chatId: chat.id,
                chatName: chat.name,
                chatType: chat.type,
                senderFullName: user.fullName,
                senderUsername: user.name,
                sentTimestamp: Date.now.timeIntervalSince1970,
                recipientFcmTokens: recipientFcmTokens
            )
            
            try await DatabaseService.shared.sendChatMessage(chatMessage: newChatMessage, chat: chat)

            return newChatMessage
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }

    func addChatViewer() async {
        guard let chat else {
            viewState = .error(message: "Something went wrong while fetching this chat's info. Please ensure you have an internet connection, restart The Same Page, and try again.")
            return
        }

        do {
            try await DatabaseService.shared.addUserToCurrentChatViewers(uid: AuthController.getLoggedInUid(), chatId: chat.id)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func removeChatViewer() async {
        guard let chat else {
            viewState = .error(message: "Something went wrong while fetching this chat's info. Please ensure you have an internet connection, restart The Same Page, and try again.")
            return
        }

        do {
            try await DatabaseService.shared.removeUserFromCurrentChatViewers(uid: AuthController.getLoggedInUid(), chatId: chat.id)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func addUserToChatUpToDateParticipantUids(chat: Chat) async {
        do {
            try await DatabaseService.shared.addUserToChatUpToDateParticipantUids(add: AuthController.getLoggedInUid(), to: chat)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func removeChatListener() {
        chatMessagesListener?.remove()
    }
}
