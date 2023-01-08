//
//  ChatMessageTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/8/23.
//

@testable import TheSamePage

import XCTest

final class ChatMessageTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    func test_SenderIsLoggedInUser_ReturnsTrueWhenSenderIsLoggedInUser() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let chatMessage = TestingConstants.exampleChatMessageJulian

        XCTAssertTrue(chatMessage.senderIsLoggedInUser, "Julian is logged in and Julian is the message sender")
    }

    func test_SenderIsLoggedInUser_ReturnsFalseWhenSenderIsNotLoggedInUser() async throws {
        try await testingDatabaseService.logInToEricAccount()
        let chatMessage = TestingConstants.exampleChatMessageJulian

        XCTAssertFalse(chatMessage.senderIsLoggedInUser, "Eric is logged in, but Julian is the message sender")
    }

    func test_DateSentUnixDateAsDate_ReturnsCorrectValue() {
        let chatMessage = TestingConstants.exampleChatMessageJulian

        XCTAssertEqual(
            chatMessage.sentUnixDateAsDate.formatted(date: .complete, time: .complete),
            Date(timeIntervalSince1970: chatMessage.sentTimestamp).formatted(date: .complete, time: .complete)
        )
    }
}
