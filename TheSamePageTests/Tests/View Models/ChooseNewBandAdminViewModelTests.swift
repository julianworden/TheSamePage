//
//  ChooseNewBandAdminViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 2/1/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class ChooseNewBandAdminViewModelTests: XCTestCase {
    var sut: ChooseNewBandAdminViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy
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
        sut = ChooseNewBandAdminViewModel(band: patheticFallacy)

        XCTAssertTrue(sut.usersPlayingInBand.isEmpty)
        XCTAssertFalse(sut.selectNewBandAdminConfirmationAlertIsShowing)
        XCTAssertFalse(sut.bandAdminIsBeingSet)
        XCTAssertFalse(sut.newAdminSelectionWasSuccessful)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoading)
        XCTAssertEqual(sut.band, patheticFallacy)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut = ChooseNewBandAdminViewModel(band: patheticFallacy)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.bandAdminIsBeingSet)
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut = ChooseNewBandAdminViewModel(band: patheticFallacy)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.newAdminSelectionWasSuccessful)
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = ChooseNewBandAdminViewModel(band: patheticFallacy)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
        XCTAssertFalse(sut.bandAdminIsBeingSet)
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = ChooseNewBandAdminViewModel(band: patheticFallacy)

        sut.viewState = .displayingView

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnGetUsersPlayingInBandForBandWithMembers_MembersAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ChooseNewBandAdminViewModel(band: patheticFallacy)

        await sut.getUsersPlayingInBand()

        XCTAssertEqual(sut.viewState, .dataLoaded)
        XCTAssertEqual(sut.usersPlayingInBand.count, 1, "Lou is the only members of this band that isn't also the band admin.")
        XCTAssertFalse(sut.usersPlayingInBand.contains(julian), "Julian is already the band admin, so he shouldn't be in this array.")
        XCTAssertTrue(sut.usersPlayingInBand.contains(lou))
    }

    func test_OnGetUsersPlayingInBandForBandWithNoMembers_NoMembersAreFetchedAndViewStateIsSet() async throws {
        var patheticFallacyDup = patheticFallacy
        patheticFallacyDup.memberUids.removeAll()
        try await testingDatabaseService.logInToJulianAccount()
        sut = ChooseNewBandAdminViewModel(band: patheticFallacyDup)

        await sut.getUsersPlayingInBand()

        XCTAssertEqual(sut.viewState, .dataNotFound)
        XCTAssertTrue(sut.usersPlayingInBand.isEmpty, "All members should've been removed from the band.")
    }

    func test_OnSetNewBandAdminWithExistingBandMember_NewAdminIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ChooseNewBandAdminViewModel(band: patheticFallacy)

        await sut.setNewBandAdmin(user: lou)
        let updatedPatheticFallacy = try await testingDatabaseService.getBand(withId: patheticFallacy.id)

        XCTAssertEqual(sut.viewState, .workCompleted)
        XCTAssertEqual(updatedPatheticFallacy.adminUid, lou.id)

        try await testingDatabaseService.editBandInfo(bandId: patheticFallacy.id, field: FbConstants.adminUid, newValue: julian.id)
    }

    func test_OnSetNewBandAdminWithUserNotInBand_NewAdminIsNotSetAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ChooseNewBandAdminViewModel(band: patheticFallacy)

        await sut.setNewBandAdmin(user: mike)
        let updatedPatheticFallacy = try await testingDatabaseService.getBand(withId: patheticFallacy.id)

        XCTAssertEqual(sut.viewState, .error(message: "Failed to designate new band admin. Please try again. Please confirm you have an internet connection. System error: Mike Florentine cannot be the admin of this band because they are not currently a member of the band."))
        XCTAssertEqual(updatedPatheticFallacy.adminUid, julian.id)
    }
}
