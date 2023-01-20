//
//  ShowSettingsViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/15/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class ShowSettingsViewModelTests: XCTestCase {
    var sut: ShowSettingsViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    /// Makes it easier to delete an example show that's created for testing in tearDown method. Any show
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdShowId: String?

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDown() async throws {
        if let createdShowId {
            try await testingDatabaseService.deleteShow(withId: createdShowId)
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = ShowSettingsViewModel(show: dumpweedExtravaganza)

        XCTAssertFalse(sut.cancelShowAlertIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = ShowSettingsViewModel(show: dumpweedExtravaganza)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = ShowSettingsViewModel(show: dumpweedExtravaganza)

        sut.viewState = .dataNotFound

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnCancelShow_ShowIsCancelledSuccessfully() async throws {
        var dumpweedExtravaganzaDup = dumpweedExtravaganza
        dumpweedExtravaganzaDup.id = ""
        self.createdShowId = try await testingDatabaseService.createShow(dumpweedExtravaganzaDup)
        let createdShow = try await testingDatabaseService.getShow(withId: createdShowId!)
        sut = ShowSettingsViewModel(show: createdShow)

        await sut.cancelShow()
        let showExists = try await testingDatabaseService.showExists(createdShow)

        XCTAssertFalse(showExists, "The show should've been deleted")

        self.createdShowId = nil
    }
}
