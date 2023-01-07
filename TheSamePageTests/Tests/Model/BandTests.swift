//
//  BandTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/6/23.
//

@testable import TheSamePage

import XCTest

final class BandTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    func test_LoggedInAsBandAdmin_LoggedInUserIsBandAdminReturnsTrue() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertTrue(patheticFallacy.loggedInUserIsBandAdmin, "Julian is the band admin of Pathetic Fallacy")
    }

    func test_LoggedInAsNonBandAdmin_LoggedInUserIsBandAdminReturnsFalse() async throws {
        try await testingDatabaseService.logInToEricAccount()

        XCTAssertFalse(patheticFallacy.loggedInUserIsBandAdmin, "Eric is not the band admin of Pathetic Fallacy")
    }

    func test_LoggedInAsBandMember_LoggedInUserIsBandMemberReturnsTrue() async throws {
        try await testingDatabaseService.logInToLouAccount()

        XCTAssertTrue(patheticFallacy.loggedInUserIsBandMember, "Lou is a member of Pathetic Fallacy")
    }

    func test_LoggedInAsNonBandMember_LoggedInUserIsBandMemberReturnsFalse() async throws {
        try await testingDatabaseService.logInToEricAccount()

        XCTAssertFalse(patheticFallacy.loggedInUserIsBandMember, "Eric is not a member of Pathetic Fallacy")
    }

    func test_LoggedInAsUserNotInvolvedWithBand_LoggedInUserIsNotInvolvedWithBandReturnsTrue() async throws {
        try await testingDatabaseService.logInToMikeAccount()

        XCTAssertTrue(patheticFallacy.loggedInUserIsNotInvolvedWithBand, "Mike is not a member, or the admin, of Pathetic Fallacy")
    }

    func test_LoggedInAsBandAdmin_LoggedInUserIsNotInvolvedWithBandReturnsFalse() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertFalse(patheticFallacy.loggedInUserIsNotInvolvedWithBand, "Julian is the band admin of Pathetic Fallacy")
    }

    func test_LoggedInAsBandMember_LoggedInUserIsNotInvolvedWithBandReturnsFalse() async throws {
        try await testingDatabaseService.logInToLouAccount()

        XCTAssertFalse(patheticFallacy.loggedInUserIsNotInvolvedWithBand, "Lou is a member of Pathetic Fallacy")
    }

    func test_LoggedInAsUserNotInvolvedWithBand_LoggedInUserIsInvolvedWithBandReturnsFalse() async throws {
        try await testingDatabaseService.logInToMikeAccount()

        XCTAssertFalse(patheticFallacy.loggedInUserIsInvolvedWithBand, "Mike is not a member, or the admin, of Pathetic Fallacy")
    }

    func test_LoggedInAsBandAdmin_LoggedInUserIsInvolvedWithBandReturnsTrue() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertTrue(patheticFallacy.loggedInUserIsInvolvedWithBand, "Julian is the band admin of Pathetic Fallacy")
    }

    func test_LoggedInAsBandMember_LoggedInUserIsInvolvedWithBandReturnsTrue() async throws {
        try await testingDatabaseService.logInToLouAccount()

        XCTAssertTrue(patheticFallacy.loggedInUserIsInvolvedWithBand, "Lou is a member of Pathetic Fallacy")
    }
}
