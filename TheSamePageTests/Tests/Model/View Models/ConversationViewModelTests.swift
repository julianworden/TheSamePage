//
//  ConversationViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/9/23.
//

@testable import TheSamePage

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

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToEricAccount()
    }

    override func tearDown() async throws {
        if let createdChatId {
            try await testingDatabaseService.deleteChat(withId: createdChatId)
            self.createdChatId = nil
        }

        if let createdShowId {
            try await testingDatabaseService.deleteShow(with: createdShowId)
            self.createdShowId = nil
        }

        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    func test_OnInitWithShowWithMessagesAndOnAppearMethodsCalled_PropertiesAreAssigned() async throws {
        let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
        let showParticipants = [
            TestingConstants.exampleShowParticipantDumpweedInDumpweedExtravaganza,TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza
        ]
        sut = ConversationViewModel(show: dumpweedExtravaganza, showParticipants: showParticipants)

        await sut.callOnAppearMethods()
        let fetchedShowChat = try await testingDatabaseService.getChat(forShowWithId: dumpweedExtravaganza.id)
        let fetchedShowChatMessages = try await testingDatabaseService.getAllChatMessages(in: fetchedShowChat)

        XCTAssertTrue(sut.messageText.isEmpty)
        XCTAssertEqual(fetchedShowChatMessages.count, sut.messages.count)
        XCTAssertEqual(sut.showParticipants, showParticipants)
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

    func test_OnConfigureChatForShowWithNoExistingChat_ChatIsCreatedForShow() async throws {
        var show = TestingConstants.exampleShowForIntegrationTesting
        show.id = try testingDatabaseService.createShow(show)
        self.createdShowId = show.id
        sut = ConversationViewModel(show: show)

        self.createdChatId = await sut.configureChat()
        let createdChat = try await testingDatabaseService.getChat(forShowWithId: show.id)
        let chatCount = try await testingDatabaseService.getTotalChatCountInFirestore()

        XCTAssertEqual(createdChat.name, show.name, "The name of the chat should match the name of the show")
        XCTAssertEqual(createdChat.showId, show.id, "The show's document ID should be in the chat's showId property")
        XCTAssertEqual(createdChat.participantUids, show.participantUids, "The chat and show should have the same participant UIDs")
        XCTAssertEqual(chatCount, 2, "There should now be two chats total in Firestore Emulator")
    }

    func test_OnConfigureChatWithExistingMessages_MessagesAreSortedInCorrectOrder() async throws {
        sut = ConversationViewModel(show: TestingConstants.exampleShowDumpweedExtravaganza)

        _ = await sut.configureChat()

        XCTAssertEqual(sut.messages, [TestingConstants.exampleChatMessageEric, TestingConstants.exampleChatMessageJulian], "Eric's message was sent first, show it should be before Julian's in the array")
    }

    func test_OnSendChatMessage_ChatListenerUpdatesMessagesArray() async throws {
        let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
        let showParticipants = [
            TestingConstants.exampleShowParticipantDumpweedInDumpweedExtravaganza,TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza
        ]
        sut = ConversationViewModel(show: dumpweedExtravaganza, showParticipants: showParticipants)
        await sut.callOnAppearMethods()
        sut.messageText = TestingConstants.testMessageText

        await sut.sendMessageButtonTapped(by: try testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserEric))
        try await Task.sleep(seconds: 3)

        XCTAssertTrue(sut.messageText.isEmpty, "After sending a message, there should be no more message text")
        XCTAssertEqual(sut.messages.count, 3, "There should now be three messages in the chat")

        try await testingDatabaseService.deleteChatMessage(inChatWithId: sut.chat!.id, withMessageText: TestingConstants.testMessageText)
    }

    func test_OnSendChatMessageWithEmptyText_ErrorViewStateIsSet() async throws {
        sut = ConversationViewModel(show: TestingConstants.exampleShowDumpweedExtravaganza)
        _ = await sut.configureChat()
        sut.messageText = "  "

        await sut.sendChatMessage(fromUser: try testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserEric))

        XCTAssertEqual(sut.viewState, .error(message: LogicError.emptyChatMessage.localizedDescription))
        XCTAssertTrue(sut.errorAlertIsShowing, "The error alert should be showing since the message is empty")
        XCTAssertEqual(sut.errorAlertText, LogicError.emptyChatMessage.localizedDescription, "The error message should be assigned")
    }

    func test_OnSendChatMessageWithoutConfiguringChat_ErrorViewStateIsSet() async throws {
        sut = ConversationViewModel()

        await sut.sendChatMessage(fromUser: try testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserEric))

        XCTAssertEqual(
            sut.viewState,
            .error(
                message: LogicError.unexpectedNilValue(message: "Failed to send chat message. Please relaunch The Same Page and try again").localizedDescription
            ),
            "This error should be thrown because configureChat was not called"
        )
        XCTAssertTrue(sut.errorAlertIsShowing, "The error alert should be showing because configureChat was not called")
        XCTAssertEqual(sut.errorAlertText, LogicError.unexpectedNilValue(message: "Failed to send chat message. Please relaunch The Same Page and try again").localizedDescription, "The error message should be assigned")
    }

    func test_OnErrorViewState_ExpectedBehaviorOccurs() {
        sut = ConversationViewModel()

        sut.viewState = .error(message: "TEST ERROR MESSAGE")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR MESSAGE")
        XCTAssertTrue(sut.errorAlertIsShowing)
    }
}
