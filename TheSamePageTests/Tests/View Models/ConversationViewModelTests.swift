//
//  ConversationViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/9/23.
//

@testable import TheSamePage

import FirebaseFirestore
import XCTest

@MainActor
final class ConversationViewModelTests: XCTestCase {
    var sut: ConversationViewModel!
    var testingDatabaseService: TestingDatabaseService!
    /// Makes it easier to delete an example chat that's created for testing in tearDown method. Any chat
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdChatId: String?
    /// Makes it easier to delete an example show that's created for testing in tearDown method. Any show
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdShowId: String?
    var createdChatMessageId: String?
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let dumpweedExtravaganzaChat = TestingConstants.exampleChatDumpweedExtravaganza
    let lou = TestingConstants.exampleUserLou
    let eric = TestingConstants.exampleUserEric
    let julian = TestingConstants.exampleUserJulian

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDown() async throws {
        if let createdChatId {
            try await testingDatabaseService.deleteChat(withId: createdChatId)
            self.createdChatId = nil
        }

        if let createdShowId {
            try await testingDatabaseService.deleteShow(withId: createdShowId)
            self.createdShowId = nil
        }

        try await testingDatabaseService.restoreChat(dumpweedExtravaganzaChat)
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
        sut = nil
    }

    func test_OnInitWithShowWithMessages_PropertiesAreAssigned() async throws {
        try await testingDatabaseService.logInToLouAccount()
        sut = ConversationViewModel(chat: nil, show: dumpweedExtravaganza, chatParticipantUids: dumpweedExtravaganza.participantUids)
        await sut.callOnAppearMethods()
        try await Task.sleep(seconds: 0.5)

        let fetchedShowChat = try await testingDatabaseService.getChat(withId: dumpweedExtravaganza.chatId!)
        let fetchedShowChatMessages = try await testingDatabaseService.getAllChatMessages(in: fetchedShowChat)

        XCTAssertTrue(sut.messageText.isEmpty)
        XCTAssertGreaterThan(fetchedShowChatMessages.count, sut.messages.count)
        XCTAssertEqual(sut.messages.count, 20)
        XCTAssertEqual(sut.chatParticipantUids, dumpweedExtravaganza.participantUids)
        XCTAssertTrue(sut.sendButtonIsDisabled)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoaded)
        XCTAssertNotNil(sut.chatMessagesListener)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertNil(sut.userId)
        XCTAssertNotNil(sut.chat)
        XCTAssertEqual(sut.chat, fetchedShowChat)
    }

    func test_OnInitWithChatId_PropertiesAreAssigned() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil, chatId: dumpweedExtravaganzaChat.id)

        XCTAssertTrue(sut.messageText.isEmpty)
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertTrue(sut.chatParticipantUids.isEmpty)
        XCTAssertTrue(sut.sendButtonIsDisabled)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoading)
        XCTAssertNil(sut.chatMessagesListener)
        XCTAssertNil(sut.show)
        XCTAssertNil(sut.userId)
        XCTAssertNil(sut.chat)
    }

    func test_OnInitWithChat_PropertiesAreAssigned() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: dumpweedExtravaganzaChat)

        XCTAssertTrue(sut.messageText.isEmpty)
        XCTAssertTrue(sut.messages.isEmpty)
        XCTAssertTrue(sut.chatParticipantUids.isEmpty)
        XCTAssertTrue(sut.sendButtonIsDisabled)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.chat, dumpweedExtravaganzaChat)
        XCTAssertEqual(sut.viewState, .dataLoading)
        XCTAssertNil(sut.chatMessagesListener)
        XCTAssertNil(sut.show)
        XCTAssertNil(sut.userId)
        XCTAssertEqual(sut.chat, dumpweedExtravaganzaChat)
    }

    func test_OnConfigureChatForShowWithNoExistingChat_ChatIsCreatedForShow() async throws {
        try await testingDatabaseService.logInToEricAccount()
        var show = TestingConstants.exampleShowForIntegrationTesting
        show.id = try await testingDatabaseService.createShow(show)
        self.createdShowId = show.id
        sut = ConversationViewModel(chat: nil, show: show)
        await sut.callOnAppearMethods()

        let updatedShowWithChatId = try await testingDatabaseService.getShow(withId: createdShowId!)
        let createdChat = try await testingDatabaseService.getChat(withId: updatedShowWithChatId.chatId!)
        self.createdChatId = createdChat.id

        XCTAssertEqual(createdChat.name, show.name, "The name of the chat should match the name of the show")
        XCTAssertEqual(createdChat.showId, show.id, "The show's document ID should be in the chat's showId property")
        XCTAssertTrue(createdChat.participantUsernames.contains(eric.name))
    }

    func test_OnInitWithChatWithExistingMessages_MessagesAreSortedInCorrectOrder() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil, show: dumpweedExtravaganza)
        await sut.callOnAppearMethods()
        try await Task.sleep(seconds: 0.5)

        XCTAssertGreaterThan(sut.messages.last!.sentTimestamp, sut.messages.first!.sentTimestamp, "The message that's last in the array should have the greatest timestamp since it was sent most recently.")
    }

    func test_OnSendChatMessage_ChatListenerUpdatesMessagesArray() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil, show: dumpweedExtravaganza, chatParticipantUids: [])
        await sut.callOnAppearMethods()
        sut.messageText = TestingConstants.testMessageText

        await sut.sendMessageButtonTapped(by: try testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserEric.id))
        try await Task.sleep(seconds: 0.5)

        XCTAssertTrue(sut.messageText.isEmpty, "After sending a message, there should be no more message text")
        XCTAssertEqual(sut.messages.last!.text, TestingConstants.testMessageText)
        XCTAssertEqual(sut.messages.count, 20, "There should still be 20 messages in the chat, even after a new one was sent.")

        try await testingDatabaseService.deleteChatMessage(inChatWithId: sut.chat!.id, withMessageText: TestingConstants.testMessageText)
    }

    func test_OnSendChatMessage_ChatPropertiesAreUpdated() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil, show: dumpweedExtravaganza, chatParticipantUids: dumpweedExtravaganza.participantUids)
        await sut.callOnAppearMethods()
        sut.messageText = TestingConstants.testMessageText

        let newChatMessage = await sut.sendMessageButtonTapped(by: try testingDatabaseService.getUserFromFirestore(withUid: eric.id))
        let updatedChat = try await testingDatabaseService.getChat(withId: dumpweedExtravaganza.chatId!)

        XCTAssertEqual(updatedChat.mostRecentMessageTimestamp, newChatMessage!.sentTimestamp)
        XCTAssertEqual(updatedChat.mostRecentMessageText, newChatMessage!.text)
        XCTAssertEqual(updatedChat.upToDateParticipantUids, [eric.id])
        XCTAssertEqual(updatedChat.mostRecentMessageSenderUsername, eric.name)

        try await testingDatabaseService.deleteChatMessage(inChatWithId: updatedChat.id, withMessageText: TestingConstants.testMessageText)
    }

    func test_OnSendChatMessage_ChatListenerDoesNotUpdateArrayAfterListenerHasBeenRemoved() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil, show: dumpweedExtravaganza, chatParticipantUids: dumpweedExtravaganza.participantUids)
        await sut.callOnAppearMethods()
        try await Task.sleep(seconds: 0.5)
        sut.messageText = TestingConstants.testMessageText

        sut.removeChatListener()
        await sut.sendMessageButtonTapped(by: eric)

        XCTAssertTrue(sut.messageText.isEmpty, "After sending a message, there should be no more message text")
        XCTAssertNotEqual(sut.messages.last?.text, TestingConstants.testMessageText)
        XCTAssertEqual(sut.messages.count, 20, "There should still be 20 messages in the chat, even after a new one was sent.")

        try await testingDatabaseService.deleteChatMessage(inChatWithId: sut.chat!.id, withMessageText: TestingConstants.testMessageText)
    }

    func test_OnSendMessageToUserWithNoExistingChat_ChatIsCreated() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil, chatParticipantUids: [AuthController.getLoggedInUid(), julian.id])
        await sut.callOnAppearMethods()
        sut.messageText = TestingConstants.testMessageText

        let sentChatMessage = await sut.sendMessageButtonTapped(by: eric)
        self.createdChatMessageId = sentChatMessage!.id
        self.createdChatId = sentChatMessage!.chatId
        let createdChat = try await testingDatabaseService.getChat(withId: createdChatId!)

        XCTAssertTrue(createdChat.participantUids.contains(eric.id))
        XCTAssertTrue(createdChat.participantUids.contains(julian.id))
        XCTAssertEqual(createdChat.participantUids.count, 2)
        XCTAssertTrue(createdChat.participantUsernames.contains(eric.name))
        XCTAssertTrue(createdChat.participantUsernames.contains(julian.name))
        XCTAssertEqual(createdChat.participantUsernames.count, 2)
    }

    func test_OnGetMoreMessages_MoreMessagesAreFetched() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil, show: dumpweedExtravaganza, chatParticipantUids: [])
        await sut.callOnAppearMethods()
        try await Task.sleep(seconds: 0.5)

        await sut.getMoreMessages(before: sut.messages.first!.sentTimestamp)
        let allChatMessages = try await testingDatabaseService.getAllChatMessages(in: TestingConstants.exampleChatDumpweedExtravaganza)

        XCTAssertEqual(sut.messages.count, allChatMessages.count)
    }

    func test_OnSendChatMessageWithEmptyText_ErrorViewStateIsSet() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil, show: dumpweedExtravaganza)
        _ = await sut.configureShowChat(forShow: dumpweedExtravaganza)
        sut.messageText = "  "

        _ = await sut.sendChatMessage(fromUser: try testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserEric.id))

        XCTAssertEqual(sut.viewState, .error(message: LogicError.emptyChatMessage.localizedDescription))
        XCTAssertTrue(sut.errorAlertIsShowing, "The error alert should be showing since the message is empty")
        XCTAssertEqual(sut.errorAlertText, LogicError.emptyChatMessage.localizedDescription, "The error message should be assigned")
    }

    func test_OnSendChatMessageWithoutConfiguringChat_ErrorViewStateIsSet() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil)

        _ = await sut.sendChatMessage(fromUser: try testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserEric.id))

        XCTAssertEqual(
            sut.viewState,
            .error(
                message: "Failed to send chat message. Please relaunch The Same Page and try again."
            ),
            "This error should be thrown because configureChat was not called"
        )
        XCTAssertTrue(sut.errorAlertIsShowing, "The error alert should be showing because configureChat was not called")
        XCTAssertEqual(sut.errorAlertText, "Failed to send chat message. Please relaunch The Same Page and try again.", "The error message should be assigned")
    }

    func test_OnErrorViewState_ExpectedBehaviorOccurs() async throws {
        try await testingDatabaseService.logInToEricAccount()
        sut = ConversationViewModel(chat: nil)

        sut.viewState = .error(message: "TEST ERROR MESSAGE")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR MESSAGE")
        XCTAssertTrue(sut.errorAlertIsShowing)
    }
}
