//
//  ShowParticipantTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/25/23.
//

@testable import TheSamePage

import XCTest

final class ShowParticipantTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    func test_BandAdminIsLoggedInUser_ReturnsTrueWhenLoggedInUserIsBandAdmin() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertTrue(TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza.bandAdminIsLoggedInUser, "Julian is the band admin of Pathetic Fallacy and he's also logged in.")
    }

    func test_BandAdminIsLoggedInUser_ReturnsFalseWhenLoggedInUserIsNotBandAdmin() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertFalse(TestingConstants.exampleShowParticipantDumpweedInDumpweedExtravaganza.bandAdminIsLoggedInUser, "Eric is the band admin of Pathetic Fallacy, but Julian is logged in.")
    }
}
