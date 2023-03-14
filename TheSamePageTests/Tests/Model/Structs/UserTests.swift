//
//  UserTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/8/23.
//

@testable import TheSamePage

import XCTest

final class UserTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!
    let julian = TestingConstants.exampleUserJulian

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    func test_ProfileBelongsToLoggedInUser_ReturnsTrueWhenProfileBelongsToLoggedInUser() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertTrue(julian.isLoggedInUser, "Julian is signed in")
    }

    func test_ProfileBelongsToLoggedInUser_ReturnsFalseWhenProfileDoesNotBelongToLoggedInUser() async throws {
        try await testingDatabaseService.logInToLouAccount()

        XCTAssertFalse(julian.isLoggedInUser, "Julian is not signed in")
    }

    func test_fullName_ReturnsCorrectValue() {
        XCTAssertEqual(julian.fullName, "Julian Worden")
    }
}
