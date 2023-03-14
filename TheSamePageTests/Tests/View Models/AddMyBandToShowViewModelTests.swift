//
//  AddMyBandToShowViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/19/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class AddMyBandToShowViewModelTests: XCTestCase {
    var sut: AddMyBandToShowViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy
    let craigAndTheFettuccinis = TestingConstants.exampleBandCraigAndTheFettuccinis
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let appleParkThrowdown = TestingConstants.exampleShowAppleParkThrowdown

    override func setUpWithError() throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = AddMyBandToShowViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertTrue(sut.userBands.isEmpty)
        XCTAssertNil(sut.selectedBand)
        XCTAssertFalse(sut.buttonsAreDisabled)
        XCTAssertFalse(sut.bandAddedSuccessfully)
        XCTAssertFalse(sut.invalidRequestAlertIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertTrue(sut.invalidRequestAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoading)
    }

    func test_OnPerformingWorkViewState_ExpectedWorkIsPerformed() {
        sut = AddMyBandToShowViewModel(show: dumpweedExtravaganza)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.buttonsAreDisabled, "The button should be disabled while work is being performed")
    }

    func test_OnWorkCompletedViewState_ExpectedWorkIsPerformed() {
        sut = AddMyBandToShowViewModel(show: dumpweedExtravaganza)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.bandAddedSuccessfully, "If this view state is set, it means that the show was successfully altered or created")
    }

    func test_OnErrorViewState_ExpectedWorkIsPerformed() {
        sut = AddMyBandToShowViewModel(show: dumpweedExtravaganza)

        sut.viewState = .error(message: "AN ERROR HAPPENED")

        XCTAssertTrue(sut.errorAlertIsShowing, "An error alert should be presented")
        XCTAssertEqual(sut.errorAlertText, "AN ERROR HAPPENED", "The error message should be assigned to the text property")
        XCTAssertFalse(sut.buttonsAreDisabled, "The user should be able to retry after an error occurs")
    }

    func test_OnInvalidViewState_PropertiesAreChanged() {
        sut = AddMyBandToShowViewModel(show: dumpweedExtravaganza)

        sut.viewState = .displayingView

        XCTAssertTrue(sut.errorAlertIsShowing)
        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
    }

    func test_OnGetLoggedInUserBands_DataIsFetchedWhenExpected() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = AddMyBandToShowViewModel(show: dumpweedExtravaganza)
        await sut.getLoggedInUserAdminBands()

        XCTAssertEqual(sut.selectedBand, patheticFallacy, "Pathetic Fallacy should be the default selected band because that's Julian's only band")
        XCTAssertEqual(sut.viewState, .dataLoaded)
        XCTAssertEqual(sut.userBands.count, 1, "Julian is only the admin of 1 band")
        XCTAssertEqual(sut.userBands.first!, patheticFallacy, "Julian is only the admin of Pathetic Fallacy")
    }

    func test_OnGetLoggedInUserBands_NoDataIsFetchedWhenExpected() async throws {
        try await testingDatabaseService.logInToLouAccount()
        sut = AddMyBandToShowViewModel(show: dumpweedExtravaganza)

        await sut.getLoggedInUserAdminBands()

        XCTAssertNil(sut.selectedBand, "Lou is not the admin of any bands")
        XCTAssertEqual(sut.viewState, .dataNotFound, "No data should've been fetched")
        XCTAssertTrue(sut.userBands.isEmpty, "Lou is not the admin of any bands")
    }

    func test_OnAddBandToShow_BandIsAddedToShow() async throws {
        try await testingDatabaseService.logInToCraigAccount()
        sut = AddMyBandToShowViewModel(show: appleParkThrowdown)
        sut.selectedBand = craigAndTheFettuccinis

        await sut.addBandToShow()
        let appleParkThrowdownWithNewParticipants = try await  testingDatabaseService.getShow(withId: appleParkThrowdown.id)
        let craigAndTheFettuccinisExistsInShowParticipants = try await testingDatabaseService.bandExistsInParticipantsCollectionForShow(showId: appleParkThrowdown.id, bandId: craigAndTheFettuccinis.id)

        XCTAssertEqual(appleParkThrowdownWithNewParticipants.bandIds.count, 2, "Two bands are now playing this show")
        XCTAssertTrue(craigAndTheFettuccinisExistsInShowParticipants, "The band should've been added to the show's participants array")
        XCTAssertEqual(sut.viewState, .workCompleted)

        try await testingDatabaseService.removeBandFromShow(bandId: craigAndTheFettuccinis.id, showId: appleParkThrowdown.id)
        try await testingDatabaseService.restoreShow(appleParkThrowdown)
    }

    func test_OnAddBandThatIsAlreadyPlayingShow_ErrorIsThrown() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = AddMyBandToShowViewModel(show: dumpweedExtravaganza)
        await sut.getLoggedInUserAdminBands()

        await sut.addBandToShow()

        XCTAssertEqual(sut.invalidRequestAlertText, ErrorMessageConstants.bandIsAlreadyPlayingShow, "Pathetic Fallacy is already playing the show")
        XCTAssertTrue(sut.invalidRequestAlertIsShowing, "Pathetic Fallacy is already playing the show, so the invite shouldn't get sent")
    }

    func test_OnSendShowInviteForShowWithFullLineup_ErrorIsThrown() async throws {
        try await testingDatabaseService.logInToCraigAccount()
        var appleParkThrowdownDup = appleParkThrowdown
        appleParkThrowdownDup.maxNumberOfBands = 1
        sut = AddMyBandToShowViewModel(show: appleParkThrowdownDup)
        sut.selectedBand = craigAndTheFettuccinis

        await sut.addBandToShow()

        XCTAssertEqual(sut.invalidRequestAlertText, ErrorMessageConstants.showLineupIsFullOnSendShowInvite, "The max number of bands for the show is 1, and 1 band is already playing")
        XCTAssertTrue(sut.invalidRequestAlertIsShowing, "The show's lineup is full, so nobody else can be added to the lineup")
    }
}
