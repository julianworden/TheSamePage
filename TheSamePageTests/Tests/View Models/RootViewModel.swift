//
//  RootViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/15/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class RootViewModelTests: XCTestCase {
    var sut: RootViewModel!
    var testingDatabaseService: TestingDatabaseService!

    override func setUpWithError() throws {
        sut = RootViewModel()
        testingDatabaseService = TestingDatabaseService()
        try testingDatabaseService.logOut()
    }

    override func tearDownWithError() throws {
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInitWithLoggedOutUser_ValuesAreCorrect() {
        XCTAssertEqual(sut.selectedTab, 0, "The selected tab should always be the first one by default")
        XCTAssertFalse(sut.userIsLoggedOut, "The user should be logged out")
    }

    func test_OnInitWithLoggedInUser_ValuesAreCorrect() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertEqual(sut.selectedTab, 0, "The selected tab should always be the first one by default")
        XCTAssertTrue(sut.userIsLoggedOut, "The user should be logged out")
    }
}
