//
//  BandInviteTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/6/23.
//

@testable import TheSamePage

import XCTest

final class BandInviteTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    func test_DateSentUnixDateAsDate_ReturnsCorrectValue() {
        let bandInvite = TestingConstants.exampleBandInvite

        XCTAssertEqual(
            bandInvite.dateSentUnixDateAsDate.formatted(date: .complete, time: .complete),
            Date(timeIntervalSince1970: bandInvite.dateSent).formatted(date: .complete, time: .complete))
    }
}
