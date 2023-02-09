//
//  SendShowApplicationViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 2/8/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class SendShowApplicationViewModelTests: XCTestCase {
    var sut: SendShowApplicationViewModel!
    var testingDatabaseService: TestingDatabaseService!
    /// Makes it easier to delete an example show application that's created for testing in tearDown method. Any show application
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdShowApplicationId: String?
    let julian = TestingConstants.exampleUserJulian
    let craig = TestingConstants.exampleUserCraig
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy
    let theApples = TestingConstants.exampleBandTheApples
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let appleParkThrowdown = TestingConstants.exampleShowAppleParkThrowdown

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDown() async throws {
        if let createdShowApplicationId {
            try await testingDatabaseService.deleteNotification(withId: createdShowApplicationId, forUserWithUid: julian.id)
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = SendShowApplicationViewModel(show: dumpweedExtravaganza)

        XCTAssertTrue(sut.adminBands.isEmpty)
        XCTAssertNil(sut.selectedBand)
        XCTAssertFalse(sut.buttonsAreDisabled)
        XCTAssertFalse(sut.asyncOperationCompletedSuccessfully)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.viewState, .dataLoading)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut = SendShowApplicationViewModel(show: dumpweedExtravaganza)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.buttonsAreDisabled, "The button should be disabled while work is being performed.")
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut = SendShowApplicationViewModel(show: dumpweedExtravaganza)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.asyncOperationCompletedSuccessfully, "If this viewState is set, the operation was completed successfully.")
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = SendShowApplicationViewModel(show: dumpweedExtravaganza)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
        XCTAssertFalse(sut.buttonsAreDisabled, "The user should be able to try sending again after seeing an error.")
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = SendShowApplicationViewModel(show: dumpweedExtravaganza)

        sut.viewState = .displayingView

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnGetLoggedInUserAdminBands_DataIsFetchedWhenExpected() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = SendShowApplicationViewModel(show: dumpweedExtravaganza)

        await sut.getLoggedInUserAdminBands()

        XCTAssertEqual(sut.selectedBand, patheticFallacy, "Pathetic Fallacy should be the default selected band because that's Julian's only band")
        XCTAssertEqual(sut.viewState, .dataLoaded)
        XCTAssertEqual(sut.adminBands.count, 1, "Julian is only the admin of 1 band")
        XCTAssertEqual(sut.adminBands.first!, patheticFallacy, "Julian is only the admin of Pathetic Fallacy")
    }

    func test_OnGetLoggedInUserAdminBands_NoDataIsFetchedWhenExpected() async throws {
        try await testingDatabaseService.logInToLouAccount()
        sut = SendShowApplicationViewModel(show: dumpweedExtravaganza)

        await sut.getLoggedInUserAdminBands()

        XCTAssertNil(sut.selectedBand, "Lou is not the admin of any bands")
        XCTAssertEqual(sut.viewState, .dataNotFound, "No data should've been fetched")
        XCTAssertTrue(sut.adminBands.isEmpty, "Lou is not the admin of any bands")
    }

    func test_OnSendShowApplication_ShowApplicationIsSent() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = SendShowApplicationViewModel(show: appleParkThrowdown)
        await sut.getLoggedInUserAdminBands()

        createdShowApplicationId = await sut.sendShowApplication()
        let showApplicationExists = try await testingDatabaseService.notificationExists(forUserWithUid: craig.id, notificationId: createdShowApplicationId!)

        XCTAssertEqual(sut.viewState, .workCompleted)
        XCTAssertTrue(showApplicationExists)
    }
}
