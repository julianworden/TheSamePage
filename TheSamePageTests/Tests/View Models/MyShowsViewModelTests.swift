//
//  MyShowsViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/11/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class MyShowsViewModelTests: XCTestCase {
    var sut: MyShowsViewModel!
    var testingDatabaseService: TestingDatabaseService!
    /// Makes it easier to delete an example show that's created for testing in tearDown method. Any show
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdShowId: String?

    override func setUp() async throws {
        sut = MyShowsViewModel()
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDown() async throws {
        if let createdShowId {
            try await testingDatabaseService.deleteShow(withId: createdShowId)
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertTrue(sut.upcomingPlayingShows.isEmpty)
        XCTAssertTrue(sut.upcomingHostedShows.isEmpty)
        XCTAssertEqual(sut.selectedShowType, .hosting)
        XCTAssertEqual(sut.myHostedShowsViewState, .dataLoading)
        XCTAssertEqual(sut.myPlayingShowsViewState, .dataLoading)
        XCTAssertFalse(sut.myHostedShowsErrorAlertIsShowing)
        XCTAssertTrue(sut.myHostedShowsErrorAlertText.isEmpty)
        XCTAssertFalse(sut.myPlayingShowsErrorAlertIsShowing)
        XCTAssertTrue(sut.myPlayingShowsErrorAlertText.isEmpty)
    }

    func test_OnGetHostedShowsWithLoggedInUserThatIsHostingShow_HostedShowIsFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        await sut.getHostedShows()

        XCTAssertEqual(sut.upcomingHostedShows.count, 1, "Julian is hosting 1 show")
        XCTAssertEqual(sut.myHostedShowsViewState, .dataLoaded, "Data should've been loaded")
    }

    func test_OnGetHostedShowsWithLoggedInUserThatIsNotHostingShow_NoShowsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToMikeAccount()

        await sut.getHostedShows()

        XCTAssertTrue(sut.upcomingHostedShows.isEmpty, "Mike is not hosting any shows")
        XCTAssertEqual(sut.myHostedShowsViewState, .dataNotFound, "No data should've been found")
    }

    func test_OnGetPlayingShowsWithLoggedInUserThatIsPlayingShow_PlayingShowIsFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToLouAccount()

        await sut.getPlayingShows()

        XCTAssertEqual(sut.upcomingPlayingShows.count, 1, "Lou is playing 1 show")
        XCTAssertEqual(sut.myPlayingShowsViewState, .dataLoaded, "Data should've been loaded")
    }

    func test_OnGetPlayingShowsWithLoggedInUserThatIsNotPlayingShow_NoShowsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToMikeAccount()

        await sut.getPlayingShows()

        XCTAssertTrue(sut.upcomingHostedShows.isEmpty, "Mike is not hosting any shows")
        XCTAssertEqual(sut.myPlayingShowsViewState, .dataNotFound, "No data should've been found")
    }

    func test_OnMyHostedShowsErrorViewState_PropertiesAreSet() {

        sut.myHostedShowsViewState = .error(message: "TEST ERROR MESSAGE")

        XCTAssertTrue(sut.myHostedShowsErrorAlertIsShowing)
        XCTAssertEqual(sut.myHostedShowsErrorAlertText, "TEST ERROR MESSAGE")
    }

    func test_OnMyHostedShowsInvalidViewState_PropertiesAreSet() {

        sut.myHostedShowsViewState = .displayingView

        XCTAssertTrue(sut.myHostedShowsErrorAlertIsShowing)
        XCTAssertEqual(sut.myHostedShowsErrorAlertText, ErrorMessageConstants.invalidViewState)

    }

    func test_OnPlayingShowsErrorViewState_PropertiesAreSet() {
        sut.myPlayingShowsViewState = .error(message: "TEST ERROR MESSAGE")

        XCTAssertTrue(sut.myPlayingShowsErrorAlertIsShowing)
        XCTAssertEqual(sut.myPlayingShowsErrorAlertText, "TEST ERROR MESSAGE")
    }

    func test_OnMyPlayingShowsInvalidViewState_PropertiesAreSet() {
        sut.myPlayingShowsViewState = .displayingView

        XCTAssertTrue(sut.myPlayingShowsErrorAlertIsShowing)
        XCTAssertEqual(sut.myPlayingShowsErrorAlertText, ErrorMessageConstants.invalidViewState)

    }
}
