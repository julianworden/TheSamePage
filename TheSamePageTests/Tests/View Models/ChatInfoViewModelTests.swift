//
//  ChatInfoViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 2/12/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class ChatInfoViewModelTests: XCTestCase {
    var sut: ChatInfoViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let julian = TestingConstants.exampleUserJulian
    let lou = TestingConstants.exampleUserLou
    let eric = TestingConstants.exampleUserEric

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDown() async throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = ChatInfoViewModel(show: dumpweedExtravaganza, chatParticipantUids: [julian.id])

        XCTAssertTrue(sut.chatParticipants.isEmpty)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoading)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.chatParticipantUids, [julian.id])
        XCTAssertNil(sut.showHost)
    }

    func test_OnErrorViewState_ExpectedBehaviorOccurs() {
        sut = ChatInfoViewModel(show: dumpweedExtravaganza, chatParticipantUids: [julian.id])

        sut.viewState = .error(message: "TEST ERROR MESSAGE")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR MESSAGE")
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = ChatInfoViewModel(show: dumpweedExtravaganza, chatParticipantUids: [julian.id])

        sut.viewState = .dataNotFound

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnFetchChatParticipants() async throws {
        sut = ChatInfoViewModel(show: dumpweedExtravaganza, chatParticipantUids: dumpweedExtravaganza.participantUids)

        await sut.fetchChatParticipantsAsUsers()

        XCTAssertTrue(sut.chatParticipants.contains(julian))
        XCTAssertTrue(sut.chatParticipants.contains(lou))
        XCTAssertTrue(sut.chatParticipants.contains(eric))
        XCTAssertEqual(sut.chatParticipants.count, 3)
    }

    func test_OnFetchShowHostAsUser() async throws {
        sut = ChatInfoViewModel(show: dumpweedExtravaganza, chatParticipantUids: dumpweedExtravaganza.participantUids)

        await sut.fetchShowHostAsUser()

        XCTAssertEqual(sut.showHost, julian)
        XCTAssertEqual(sut.viewState, .dataLoaded)
    }
}
