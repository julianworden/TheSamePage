//
//  AddEditShowTimeViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 2/7/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class AddEditShowTimeViewModelTests: XCTestCase {
    var sut: AddEditShowTimeViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDown() async throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
        sut = nil
    }

    func test_OnInitWithShowToEditShowTime_DefaultValuesAreCorrect() {
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganza, showTimeType: .doors)

        XCTAssertEqual(sut.showTime.timeIntervalSince1970, dumpweedExtravaganza.doorsTime)
        XCTAssertFalse(sut.buttonsAreDisabled)
        XCTAssertFalse(sut.asyncOperationCompleted)
        XCTAssertFalse(sut.deleteSetTimeConfirmationAlertIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.showTimeType, .doors)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnInitWithShowToCreateNewShowTime_DefaultValuesAreCorrect() {
        var dumpweedExtravaganzaDup = dumpweedExtravaganza
        dumpweedExtravaganzaDup.doorsTime = nil
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganzaDup, showTimeType: .doors)

        XCTAssertEqual(sut.showTime.timeIntervalSince1970, dumpweedExtravaganzaDup.date)
        XCTAssertFalse(sut.buttonsAreDisabled)
        XCTAssertFalse(sut.asyncOperationCompleted)
        XCTAssertFalse(sut.deleteSetTimeConfirmationAlertIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.show, dumpweedExtravaganzaDup)
        XCTAssertEqual(sut.showTimeType, .doors)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnPerformingWorkViewState_ExpectedWorkIsPerformed() {
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganza, showTimeType: .doors)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.buttonsAreDisabled, "The buttons should be disabled while work is being performed.")
    }

    func test_OnWorkCompletedViewState_ExpectedWorkIsPerformed() {
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganza, showTimeType: .doors)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.asyncOperationCompleted, "If this view state is set, it means that the show time was successfully created, updated, or deleted.")
    }

    func test_OnErrorViewState_ExpectedWorkIsPerformed() {
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganza, showTimeType: .doors)

        sut.viewState = .error(message: "AN ERROR HAPPENED")

        XCTAssertTrue(sut.errorAlertIsShowing, "An error alert should be presented.")
        XCTAssertEqual(sut.errorAlertText, "AN ERROR HAPPENED", "The error message should be assigned to the text property.")
        XCTAssertFalse(sut.buttonsAreDisabled, "The user should be able to retry after an error occurs.")
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganza, showTimeType: .doors)

        sut.viewState = .dataLoaded

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_ShowTimeIsBeingEdited_ReturnsFalseWhenExpected() {
        var dumpweedExtravaganzaDup = dumpweedExtravaganza
        dumpweedExtravaganzaDup.doorsTime = nil
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganzaDup, showTimeType: .doors)

        XCTAssertFalse(sut.showTimeIsBeingEdited, "The show has no doors time, so it's impossible for the doors time to be getting edited.")
    }

    func test_ShowTimeIsBeingEdited_ReturnsTrueWhenExpected() {
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganza, showTimeType: .doors)

        XCTAssertTrue(sut.showTimeIsBeingEdited, "The show has a doors time, so it must be getting edited.")
    }

    func test_OnAddShowTime_NewShowTimeIsCreated() async throws {
        var dumpweedExtravaganzaDup = dumpweedExtravaganza
        dumpweedExtravaganzaDup.musicStartTime = nil
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganzaDup, showTimeType: .musicStart)

        await sut.addShowTime()
        let updatedDumpweedExtravaganza = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)

        XCTAssertEqual(sut.viewState, .workCompleted)
        XCTAssertEqual(updatedDumpweedExtravaganza.musicStartTime, dumpweedExtravaganza.date)

        try await testingDatabaseService.restoreShow(dumpweedExtravaganza)
    }

    func test_OnAddShowTime_ExistingShowTimeIsEdited() async throws {
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganza, showTimeType: .end)
        sut.showTime += 100

        await sut.addShowTime()
        let updatedDumpweedExtravaganza = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)

        XCTAssertEqual(sut.viewState, .workCompleted)
        XCTAssertEqual(updatedDumpweedExtravaganza.endTime?.unixDateAsDate, sut.showTime)

        try await testingDatabaseService.restoreShow(dumpweedExtravaganza)
    }

    func test_OnDeleteShowTime_ExistingShowTimeIsDeleted() async throws {
        sut = AddEditShowTimeViewModel(show: dumpweedExtravaganza, showTimeType: .loadIn)

        await sut.deleteShowTime()
        let updatedDumpweedExtravaganza = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)

        XCTAssertEqual(sut.viewState, .workCompleted)
        XCTAssertNil(updatedDumpweedExtravaganza.loadInTime)

        try await testingDatabaseService.restoreShow(dumpweedExtravaganza)
    }
}
