//
//  SendShowInviteViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/15/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class SendShowInviteViewModelTests: XCTestCase {
    var sut: SendShowInviteViewModel!
    var testingDatabaseService: TestingDatabaseService!
    /// Makes it easier to delete an example show invite that's created for testing in tearDown method. Any show invite
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdShowInviteId: String?
    let julian = TestingConstants.exampleUserJulian
    let craig = TestingConstants.exampleUserCraig
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy
    let theApples = TestingConstants.exampleBandTheApples
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDown() async throws {
        if let createdShowInviteId {
            try await testingDatabaseService.deleteNotification(withId: createdShowInviteId, forUserWithUid: craig.id)
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = SendShowInviteViewModel(band: patheticFallacy)

        XCTAssertTrue(sut.userShows.isEmpty)
        XCTAssertNil(sut.selectedShow)
        XCTAssertEqual(sut.band, patheticFallacy)
        XCTAssertFalse(sut.invalidInviteAlertIsShowing)
        XCTAssertTrue(sut.invalidInviteAlertText.isEmpty)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoading)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut = SendShowInviteViewModel(band: patheticFallacy)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.sendButtonIsDisabled, "The button should be disabled while work is being performed")
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut = SendShowInviteViewModel(band: patheticFallacy)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.showInviteSentSuccessfully, "If this viewState is set, the invite was sent successfully")
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = SendShowInviteViewModel(band: patheticFallacy)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
        XCTAssertFalse(sut.sendButtonIsDisabled, "The user should be able to try sending again after seeing an error")
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = SendShowInviteViewModel(band: patheticFallacy)

        sut.viewState = .displayingView

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnSendShowInviteToBandAlreadyPlayingShow_ErrorIsThrown() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = SendShowInviteViewModel(band: patheticFallacy)
        await sut.getHostedShows()

        await sut.sendShowInvite()

        XCTAssertEqual(sut.invalidInviteAlertText, ErrorMessageConstants.bandIsAlreadyPlayingShow, "Pathetic Fallacy is already playing the show")
        XCTAssertTrue(sut.invalidInviteAlertIsShowing, "Pathetic Fallacy is already playing the show, so the invite shouldn't get sent")
    }

    func test_OnSendShowInviteForShowWithFullLineup_ErrorIsThrown() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = SendShowInviteViewModel(band: theApples)
        await sut.getHostedShows()
        sut.selectedShow!.maxNumberOfBands = 2

        await sut.sendShowInvite()

        XCTAssertEqual(sut.invalidInviteAlertText, ErrorMessageConstants.showLineupIsFullOnSendShowInvite, "The max number of bands for the show is 1, and one band is already playing")
        XCTAssertTrue(sut.invalidInviteAlertIsShowing, "The show's lineup is full, so nobody else can be invited to play")
    }

    func test_OnSendShowInvite_InviteIsSentSuccessfully() async throws {
        sut = SendShowInviteViewModel(band: theApples)
        await sut.getHostedShows()

        createdShowInviteId = await sut.sendShowInvite()
        let createdShowInvite = try await testingDatabaseService.getShowInvite(
            withId: createdShowInviteId!, forUserWithUid: craig.id
        )

        XCTAssertEqual(createdShowInvite.id, createdShowInviteId)
        XCTAssertEqual(createdShowInvite.notificationType, NotificationType.showInvite.rawValue)
        XCTAssertEqual(createdShowInvite.recipientUid, craig.id)
        XCTAssertEqual(createdShowInvite.bandId, theApples.id)
        XCTAssertEqual(createdShowInvite.showId, dumpweedExtravaganza.id)
        XCTAssertEqual(createdShowInvite.showName, dumpweedExtravaganza.name)
        XCTAssertEqual(createdShowInvite.senderUsername, julian.username)
        XCTAssertEqual(createdShowInvite.showVenue, dumpweedExtravaganza.venue)
        XCTAssertEqual(createdShowInvite.message, "\(julian.username) is inviting \(theApples.name) to play \(dumpweedExtravaganza.name) at \(dumpweedExtravaganza.venue) on \(dumpweedExtravaganza.formattedDate)")
    }

    func test_OnGetHostedShowsWithUserThatIsHostingShow_DataIsFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = SendShowInviteViewModel(band: patheticFallacy)

        await sut.getHostedShows()

        XCTAssertEqual(sut.userShows.count, 1, "Julian is only hosting one show")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been loaded")
        XCTAssertEqual(sut.selectedShow, dumpweedExtravaganza, "Dumpweed Extravaganza should be the default selected show")
    }

    func test_OnGetHostedShowsWithUserThatIsNotHostingShow_DataIsNotFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToMikeAccount()
        sut = SendShowInviteViewModel(band: patheticFallacy)

        await sut.getHostedShows()

        XCTAssertTrue(sut.userShows.isEmpty, "Mike is not hosting any shows")
        XCTAssertEqual(sut.viewState, .dataNotFound, "Data should've been loaded")
        XCTAssertNil(sut.selectedShow, "There shouldn't be a selected show because Mike isn't hosting a show")
    }
}
