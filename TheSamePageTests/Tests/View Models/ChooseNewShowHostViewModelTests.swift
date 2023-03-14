//
//  ChooseNewShowHostViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 2/1/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class ChooseNewShowHostViewModelTests: XCTestCase {
    var sut: ChooseNewShowHostViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let julian = TestingConstants.exampleUserJulian
    let eric = TestingConstants.exampleUserEric
    let mike = TestingConstants.exampleUserMike
    let lou = TestingConstants.exampleUserLou

    override func setUpWithError() throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = ChooseNewShowHostViewModel(show: dumpweedExtravaganza)

        XCTAssertTrue(sut.usersParticipatingInShow.isEmpty)
        XCTAssertFalse(sut.selectNewShowHostConfirmationAlertIsShowing)
        XCTAssertFalse(sut.showHostIsBeingSet)
        XCTAssertFalse(sut.newHostSelectionWasSuccessful)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoading)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut = ChooseNewShowHostViewModel(show: dumpweedExtravaganza)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.showHostIsBeingSet)
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut = ChooseNewShowHostViewModel(show: dumpweedExtravaganza)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.newHostSelectionWasSuccessful)
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = ChooseNewShowHostViewModel(show: dumpweedExtravaganza)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
        XCTAssertFalse(sut.showHostIsBeingSet)
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = ChooseNewShowHostViewModel(show: dumpweedExtravaganza)

        sut.viewState = .displayingView

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnGetUsersParticipatingInShow_ParticipantsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ChooseNewShowHostViewModel(show: dumpweedExtravaganza)

        await sut.getUsersParticipatingInShow()

        XCTAssertFalse(sut.usersParticipatingInShow.isEmpty, "There are two users participating in this show.")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been loaded.")
        XCTAssertEqual(sut.usersParticipatingInShow.count, 2," There are two users participating in this show.")
        print(sut.usersParticipatingInShow)
        XCTAssertTrue(sut.usersParticipatingInShow.contains(lou), "Lou is one of the users playing this show.")
        XCTAssertTrue(sut.usersParticipatingInShow.contains(eric), "Eric is one of the users playing this show.")
    }

    func test_OnGetUsersParticipatingInShowForShowThatHasNoParticipants_NoParticipantsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        var dumpweedExtravaganzaDup = dumpweedExtravaganza
        dumpweedExtravaganzaDup.participantUids.removeAll()
        sut = ChooseNewShowHostViewModel(show: dumpweedExtravaganzaDup)

        await sut.getUsersParticipatingInShow()

        XCTAssertTrue(sut.usersParticipatingInShow.isEmpty, "There are no users participating in this show.")
        XCTAssertEqual(sut.viewState, .dataNotFound, "Data should not have been loaded.")
    }

    func test_OnSetNewShowHost_NewShowHostIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ChooseNewShowHostViewModel(show: dumpweedExtravaganza)

        await sut.setNewShowHost(user: eric)
        let updatedDumpweedExtravaganza = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)

        XCTAssertEqual(sut.viewState, .workCompleted, "The method should've completed successfully and set this view state.")
        XCTAssertEqual(updatedDumpweedExtravaganza.hostUid, eric.id, "Eric should be the new show host.")
        XCTAssertNotEqual(updatedDumpweedExtravaganza.hostUid, julian.id, "Julian is no longer the show host.")

        try await testingDatabaseService.restoreShowForUpdateTesting(show: dumpweedExtravaganza)
    }

    func test_OnSetNewShowHostWithUserNotParticipatingInShow_ErrorIsThrown() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ChooseNewShowHostViewModel(show: dumpweedExtravaganza)

        await sut.setNewShowHost(user: mike)

        XCTAssertEqual(sut.viewState, .error(message: "Failed to designate new show host. Please try again. Please confirm you have an internet connection. System error: Mike Florentine cannot host this show because they are not participating in it."))
    }
}
