//
//  AddEditSetTimeViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 2/7/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class AddEditSetTimeViewModelTests: XCTestCase {
    var sut: AddEditSetTimeViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let exampleShowParticipantPatheticFallacy = TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza
    let exampleShowParticipantDumpweed = TestingConstants.exampleShowParticipantDumpweedInDumpweedExtravaganza
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
        sut = nil
    }

    func test_OnInitWithShowParticipantThatHasSetTime_DefaultValuesAreCorrect() {
        sut = AddEditSetTimeViewModel(show: dumpweedExtravaganza, showParticipant: exampleShowParticipantPatheticFallacy)

        XCTAssertEqual(sut.bandSetTime, exampleShowParticipantPatheticFallacy.setTime?.unixDateAsDate)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.showParticipant, exampleShowParticipantPatheticFallacy)
        XCTAssertFalse(sut.setTimeChangedSuccessfully)
        XCTAssertFalse(sut.buttonsAreDisabled)
        XCTAssertFalse(sut.deleteSetTimeConfirmationAlertIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnInitWithShowParticipantThatHasNoSetTime_DefaultValuesAreCorrect() {
        sut = AddEditSetTimeViewModel(show: dumpweedExtravaganza, showParticipant: exampleShowParticipantDumpweed)

        XCTAssertEqual(sut.bandSetTime, dumpweedExtravaganza.date.unixDateAsDate)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.showParticipant, exampleShowParticipantDumpweed)
        XCTAssertFalse(sut.setTimeChangedSuccessfully)
        XCTAssertFalse(sut.buttonsAreDisabled)
        XCTAssertFalse(sut.deleteSetTimeConfirmationAlertIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnPerformingWorkViewState_ExpectedWorkIsPerformed() {
        sut = AddEditSetTimeViewModel(show: dumpweedExtravaganza, showParticipant: exampleShowParticipantPatheticFallacy)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.buttonsAreDisabled, "The button should be disabled while work is being performed")
    }

    func test_OnWorkCompletedViewState_ExpectedWorkIsPerformed() {
        sut = AddEditSetTimeViewModel(show: dumpweedExtravaganza, showParticipant: exampleShowParticipantPatheticFallacy)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.setTimeChangedSuccessfully, "If this view state is set, it means that the show was successfully altered or created")
    }

    func test_OnErrorViewState_ExpectedWorkIsPerformed() {
        sut = AddEditSetTimeViewModel(show: dumpweedExtravaganza, showParticipant: exampleShowParticipantPatheticFallacy)

        sut.viewState = .error(message: "AN ERROR HAPPENED")

        XCTAssertTrue(sut.errorAlertIsShowing, "An error alert should be presented")
        XCTAssertEqual(sut.errorAlertText, "AN ERROR HAPPENED", "The error message should be assigned to the text property")
        XCTAssertFalse(sut.buttonsAreDisabled, "The user should be able to retry after an error occurs")
    }

    func test_OnAddEditSetTime_SetTimeGetsCreatedForShowParticipantThatHasNoSetTime() async throws {
        sut = AddEditSetTimeViewModel(show: dumpweedExtravaganza, showParticipant: exampleShowParticipantDumpweed)

        await sut.addEditSetTime()
        let updatedShowParticipantDumpweed = try await testingDatabaseService.getShowParticipant(exampleShowParticipantDumpweed)

        XCTAssertEqual(sut.viewState, .workCompleted)
        XCTAssertEqual(updatedShowParticipantDumpweed.setTime, dumpweedExtravaganza.date, "The bandSetTime property wasn't altered, so Dumpweed's set time should be the same as the show's date and time.")

        try testingDatabaseService.restoreShowParticipant(restore: exampleShowParticipantDumpweed, in: dumpweedExtravaganza)
    }

    func test_OnAddEditSetTime_SetTimeGetsEditedForShowParticipantThatHasSetTime() async throws {
        sut = AddEditSetTimeViewModel(show: dumpweedExtravaganza, showParticipant: exampleShowParticipantPatheticFallacy)
        sut.bandSetTime = Date(timeIntervalSince1970: exampleShowParticipantPatheticFallacy.setTime! + 100)

        await sut.addEditSetTime()
        let updatedShowParticipantPatheticFallacy = try await testingDatabaseService.getShowParticipant(
            exampleShowParticipantPatheticFallacy
        )

        XCTAssertEqual(sut.viewState, .workCompleted)
        XCTAssertEqual(updatedShowParticipantPatheticFallacy.setTime, exampleShowParticipantPatheticFallacy.setTime! + 100)

        try testingDatabaseService.restoreShowParticipant(restore: exampleShowParticipantPatheticFallacy, in: dumpweedExtravaganza)
    }

    func test_OnDeleteSetTime_SetTimeIsDeleted() async throws {
        sut = AddEditSetTimeViewModel(show: dumpweedExtravaganza, showParticipant: exampleShowParticipantPatheticFallacy)

        await sut.deleteSetTime()
        let updatedShowParticipantPatheticFallacy = try await testingDatabaseService.getShowParticipant(
            exampleShowParticipantPatheticFallacy
        )

        XCTAssertEqual(sut.viewState, .workCompleted)
        XCTAssertNil(updatedShowParticipantPatheticFallacy.setTime, "Pathetic Fallacy's set time should've been deleted.")

        try testingDatabaseService.restoreShowParticipant(restore: exampleShowParticipantPatheticFallacy, in: dumpweedExtravaganza)
    }
}
