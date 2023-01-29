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
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() throws {
        try testingDatabaseService.logOut()
        sut = RootViewModel()

        XCTAssertEqual(sut.selectedTab, 0, "The selected tab should always be the first one by default")
    }
}
