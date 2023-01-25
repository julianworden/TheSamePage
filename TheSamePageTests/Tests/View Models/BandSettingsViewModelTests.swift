//
//  BandSettingsViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/15/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class BandSettingsViewModelTests: XCTestCase {
    var sut: BandSettingsViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let exampleUserLou = TestingConstants.exampleUserLou
    let exampleBandMemberLou = TestingConstants.exampleBandMemberLou
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToLouAccount()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = BandSettingsViewModel(band: patheticFallacy)

        XCTAssertEqual(sut.band, patheticFallacy)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = BandSettingsViewModel(band: patheticFallacy)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = BandSettingsViewModel(band: patheticFallacy)

        sut.viewState = .dataNotFound

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }
}
