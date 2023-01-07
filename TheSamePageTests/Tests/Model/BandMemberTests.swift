//
//  BandMemberTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/6/23.
//

@testable import TheSamePage

import XCTest

final class BandMemberTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    func test_DateJoinedUnixDateAsDate_ReturnsCorrectValue() {
        let bandInvite = TestingConstants.exampleBandInvite

        XCTAssertEqual(
            bandInvite.dateSentUnixDateAsDate.formatted(date: .complete, time: .complete),
            "Friday, January 6, 2023 at 10:37:30 PM PST"
        )
    }

    func test_BandMemberIsLoggedInUser_BandMemberIsLoggedInUserReturnsTrue() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let julian = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberJulian,
            in: TestingConstants.exampleBandPatheticFallacy
        )

        XCTAssertTrue(julian.bandMemberIsLoggedInUser, "Julian is the fetched BandMember and the logged in user")
    }

    func test_BandMemberIsNotLoggedInUser_BandMemberIsLoggedInUserReturnsFalse() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let eric = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberEric,
            in: TestingConstants.exampleBandDumpweed
        )

        XCTAssertFalse(eric.bandMemberIsLoggedInUser, "Eric is the fetched BandMember, but not the logged in user")
    }

    func test_ListRowIconName_ReturnsCorrectValue() {
        let julian = TestingConstants.exampleBandMemberJulian

        XCTAssertEqual(julian.listRowIconName, "vocals")
    }
}
