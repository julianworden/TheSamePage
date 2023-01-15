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
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDown() async throws {
        if let createdBandInviteId {
            try await testingDatabaseService.deleteBandInvite(withId: createdBandInviteId, forUserWithUid: eric.id)
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = SendBandInviteViewModel(user: eric)
        let predicate = NSPredicate { _,_ in
            !self.sut.userBands.isEmpty
        }
        let initializerExpectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        wait(for: [initializerExpectation], timeout: 2)

        XCTAssertEqual(sut.userBands.count, 1, "Julian is a member of one band, Pathetic Fallacy")
        XCTAssertEqual(sut.selectedBand, TestingConstants.exampleBandPatheticFallacy, "Pathetic Fallacy should be the default selected band because that's Julian's only band")
        XCTAssertEqual(sut.recipientRole, .vocals)
        XCTAssertFalse(sut.sendBandInviteButtonIsDisabled)
        XCTAssertFalse(sut.bandInviteSentSuccessfully)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoaded, "The view state should've been set when Julian's band was found and assigned to userBands")
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
        XCTAssertFalse(sut.sendBandInviteButtonIsDisabled, "The button should no longer be disabled after work has completed")
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

    func test_OnSendBandInvite_BandInviteNotificationIsSentSuccessfully() async throws {
        sut = SendBandInviteViewModel(user: eric)
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
