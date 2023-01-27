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
    let exampleUserJulian = TestingConstants.exampleUserJulian
    let exampleBandMemberJulian = TestingConstants.exampleBandMemberJulian
    let exampleBandMemberLou = TestingConstants.exampleBandMemberLou
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let dumpweedExtravaganzaChat = TestingConstants.exampleChatDumpweedExtravaganza
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
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

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut = BandSettingsViewModel(band: patheticFallacy)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.buttonsAreDisabled)
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut = BandSettingsViewModel(band: patheticFallacy)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.bandDeleteWasSuccessful)
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = BandSettingsViewModel(band: patheticFallacy)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
        XCTAssertFalse(sut.buttonsAreDisabled)
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = BandSettingsViewModel(band: patheticFallacy)

        sut.viewState = .dataNotFound

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnDeleteBand_BandIsDeleted() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = BandSettingsViewModel(band: patheticFallacy)

        await sut.deleteBand()
        let updatedDumpweedExtravaganzaChat = try await testingDatabaseService.getChat(forShowWithId: dumpweedExtravaganza.id)
        let updatedDumpweedExtravaganza = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)

        do {
            _ = try await testingDatabaseService.getBand(withId: patheticFallacy.id)
            XCTFail("The band was deleted, so this method shouldn't have successfully fetched anything.")
        } catch {
            XCTAssertEqual(sut.viewState, .workCompleted)
            XCTAssertFalse(updatedDumpweedExtravaganzaChat.participantUids.contains(exampleUserLou.id), "Lou should've been removed from the show's chat since he was a part of Pathetic Fallacy")
            XCTAssertFalse(updatedDumpweedExtravaganzaChat.participantUids.contains(exampleUserJulian.id), "Julian should've been removed from the show's chat since he was a part of Pathetic Fallacy")
            XCTAssertEqual(updatedDumpweedExtravaganza.bandIds.count, 1, "There should now be one band on the show")
            XCTAssertFalse(updatedDumpweedExtravaganza.participantUids.contains(exampleUserLou.id), "Lou should've been removed from the show since he was a part of Pathetic Fallacy")
            XCTAssertFalse(updatedDumpweedExtravaganza.participantUids.contains(exampleUserJulian.id), "Julian should've been removed from the show since he was a part of Pathetic Fallacy")
        }

        try await testingDatabaseService.restorePatheticFallacy(
            band: patheticFallacy,
            show: dumpweedExtravaganza,
            chat: dumpweedExtravaganzaChat,
            showParticipant: TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza,
            bandMembers: [exampleBandMemberLou, exampleBandMemberJulian],
            links: [
                TestingConstants.examplePlatformLinkPatheticFallacyFacebook,
                TestingConstants.examplePlatformLinkPatheticFallacyInstagram
            ]
        )
    }
}
