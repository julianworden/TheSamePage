//
//  SendBandInviteViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/14/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class SendBandInviteViewModelTests: XCTestCase {
    var sut: SendBandInviteViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let eric = TestingConstants.exampleUserEric
    let julian = TestingConstants.exampleUserJulian
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy
    /// Makes it easier to delete an example band invite that's created for testing in tearDown method. Any band invite
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdBandInviteId: String?

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDown() async throws {
        if let createdBandInviteId {
            try await testingDatabaseService.deleteNotification(withId: createdBandInviteId, forUserWithUid: eric.id)
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = SendBandInviteViewModel(user: eric)

        XCTAssertEqual(sut.recipientRole, .vocals)
        XCTAssertFalse(sut.sendBandInviteButtonIsDisabled)
        XCTAssertFalse(sut.bandInviteSentSuccessfully)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoading, "The view state should've been set when Julian's band was found and assigned to userBands")
        XCTAssertEqual(sut.user, eric)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut = SendBandInviteViewModel(user: eric)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.sendBandInviteButtonIsDisabled, "The button should be disabled while work is being performed")
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut = SendBandInviteViewModel(user: eric)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.bandInviteSentSuccessfully, "If this viewState is set, the invite was sent successfully")
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = SendBandInviteViewModel(user: eric)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = SendBandInviteViewModel(user: eric)

        sut.viewState = .displayingView

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnGetLoggedInUserAdminBands_DataIsFetchedWhenExpected() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = SendBandInviteViewModel(user: eric)

        await sut.getLoggedInUserAdminBands()

        XCTAssertEqual(sut.selectedBand, patheticFallacy, "Pathetic Fallacy should be the default selected band because that's Julian's only band")
        XCTAssertEqual(sut.viewState, .dataLoaded)
        XCTAssertEqual(sut.adminBands.count, 1, "Julian is only the admin of 1 band")
        XCTAssertEqual(sut.adminBands.first!, patheticFallacy, "Julian is only the admin of Pathetic Fallacy")
    }

    func test_OnGetLoggedInUserAdminBands_NoDataIsFetchedWhenExpected() async throws {
        try await testingDatabaseService.logInToLouAccount()
        sut = SendBandInviteViewModel(user: eric)

        await sut.getLoggedInUserAdminBands()

        XCTAssertNil(sut.selectedBand, "Lou is not the admin of any bands")
        XCTAssertEqual(sut.viewState, .dataNotFound, "No data should've been fetched")
        XCTAssertTrue(sut.adminBands.isEmpty, "Lou is not the admin of any bands")
    }

    func test_OnSendBandInvite_BandInviteNotificationIsSentSuccessfully() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = SendBandInviteViewModel(user: eric)
        await sut.getLoggedInUserAdminBands()
        sut.recipientRole = .bassGuitar

        self.createdBandInviteId = await sut.sendBandInvite()
        let createdBandInvite = try await testingDatabaseService.getBandInvite(withId: createdBandInviteId!, forUserWithUid: eric.id)

        XCTAssertEqual(createdBandInvite.id, createdBandInviteId)
        XCTAssertEqual(createdBandInvite.recipientRole, Instrument.bassGuitar.rawValue)
        XCTAssertEqual(createdBandInvite.message, "\(julian.username) is inviting you to join \(patheticFallacy.name)")
        XCTAssertEqual(createdBandInvite.bandId, patheticFallacy.id)
        XCTAssertEqual(createdBandInvite.senderUsername, julian.username)
        XCTAssertEqual(createdBandInvite.senderBand, patheticFallacy.name)
        XCTAssertEqual(sut.viewState, .workCompleted, "This view state should be assigned if the send was successful")
    }
}
