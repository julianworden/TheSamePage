//
//  ChatTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/7/23.
//

@testable import TheSamePage

import XCTest

final class ChatTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    func test_ParticipantUidsWithoutSenderUid_ExcludesSenderUid() async throws {
        let julian = try await testingDatabaseService.logInToJulianAccount()
        let chat = TestingConstants.exampleChatDumpweedExtravaganza

        XCTAssertFalse(chat.participantUidsWithoutLoggedInUser.contains(julian!.uid))
    }
}
