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

    func test_OnLeaveBand_UserLeavesBand() async throws {
        sut = BandSettingsViewModel(band: patheticFallacy)

        await sut.leaveBand()
        let patheticFallacyWithoutJulian = try await testingDatabaseService.getBand(withId: patheticFallacy.id)
        let patheticFallacyUpdatedBandMembers = try await testingDatabaseService.getAllBandMembers(
            forBandWithId: patheticFallacy.id
        )
        let dumpweedExtravangaUpdated = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)
        let dumpweedExtravaganzaChatUpdated = try await testingDatabaseService.getChat(forShowWithId: dumpweedExtravaganza.id)

        XCTAssertFalse(patheticFallacyWithoutJulian.memberUids.contains(exampleUserLou.id), "Lou left PF")
        XCTAssertFalse (patheticFallacyUpdatedBandMembers.contains(exampleBandMemberLou), "Lou left PF")
        XCTAssertFalse(dumpweedExtravaganzaChatUpdated.participantUids.contains(exampleUserLou.id), "Lou should no longer be in any chats for shows that PF is playing")
        XCTAssertFalse(dumpweedExtravangaUpdated.participantUids.contains(exampleUserLou.id), "Lou should no longer be a participant in any shows that PF is playing")

        try await testingDatabaseService.restorePatheticFallacy(
            band: patheticFallacy,
            show: dumpweedExtravaganza,
            chat: TestingConstants.exampleChatDumpweedExtravaganza,
            bandMember: exampleBandMemberLou
        )
    }
}
