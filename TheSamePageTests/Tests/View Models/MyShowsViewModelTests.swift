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
            try await testingDatabaseService.deleteShow(with: createdShowId)
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertTrue(sut.playingShows.isEmpty)
        XCTAssertTrue(sut.hostedShows.isEmpty)
        XCTAssertEqual(sut.selectedShowType, .hosting)
        XCTAssertEqual(sut.myHostedShowsViewState, .dataLoading)
        XCTAssertEqual(sut.myPlayingShowsViewState, .dataLoading)
        XCTAssertFalse(sut.myHostedShowsErrorAlertIsShowing)
        XCTAssertTrue(sut.myHostedShowsErrorAlertText.isEmpty)
        XCTAssertFalse(sut.myPlayingShowsErrorAlertIsShowing)
        XCTAssertTrue(sut.myPlayingShowsErrorAlertText.isEmpty)
        XCTAssertNil(sut.hostedShowsListener)
        XCTAssertNil(sut.playingShowsListener)
    }

    func test_OnGetHostedShowsWithLoggedInUserThatIsHostingShow_HostedShowIsFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        await sut.getHostedShows()
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.hostedShows.count, 1, "Julian is hosting 1 show")
        XCTAssertEqual(sut.myHostedShowsViewState, .dataLoaded, "Data should've been loaded")
    }

    func test_OnGetHostedShowsWithLoggedInUserThatIsNotHostingShow_NoShowsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToMikeAccount()

        await sut.getHostedShows()
        try await Task.sleep(seconds: 2)

        XCTAssertTrue(sut.hostedShows.isEmpty, "Mike is not hosting any shows")
        XCTAssertEqual(sut.myHostedShowsViewState, .dataNotFound, "No data should've been found")
    }

    func test_OnHostedShowCreated_HostedShowsArrayUpdates() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        await sut.getHostedShows()
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.hostedShows.count, 1, "Julian should only be hosting 1 show at this point")

        var newShow = TestingConstants.exampleShowForIntegrationTesting
        newShow.hostUid = TestingConstants.exampleUserJulian.id
        self.createdShowId = try testingDatabaseService.createShow(newShow)
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.hostedShows.count, 2, "Julian is now hosting 2 shows")
        XCTAssertEqual(sut.myHostedShowsViewState, .dataLoaded, "Data should've been loaded")
    }

    func test_OnGetHostedShows_HostedShowsListenerIsNotNil() async {
        await sut.getHostedShows()

        XCTAssertNotNil(sut.hostedShowsListener, "The method should've assigned a value to this property")
    }

    func test_OnRemoveHostedShowsListener_ListenerIsRemoved() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        await sut.getHostedShows()
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.hostedShows.count, 1, "Julian should be hosting 1 show")

        var newShow = TestingConstants.exampleShowForIntegrationTesting
        newShow.hostUid = TestingConstants.exampleUserJulian.id

        sut.removeHostedShowsListener()

        self.createdShowId = try testingDatabaseService.createShow(newShow)
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.hostedShows.count, 1, "The second show shouldn't have been fetched because the listener was removed")
        XCTAssertEqual(sut.myHostedShowsViewState, .dataLoaded, "The view state shouldn't have changed")
    }

    func test_OnGetPlayingShowsWithLoggedInUserThatIsPlayingShow_PlayingShowIsFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToLouAccount()

        await sut.getPlayingShows()
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.playingShows.count, 1, "Lou is playing 1 show")
        XCTAssertEqual(sut.myPlayingShowsViewState, .dataLoaded, "Data should've been loaded")
    }

    func test_OnGetPlayingShowsWithLoggedInUserThatIsNotPlayingShow_NoShowsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToMikeAccount()

        await sut.getPlayingShows()
        try await Task.sleep(seconds: 2)

        XCTAssertTrue(sut.hostedShows.isEmpty, "Mike is not hosting any shows")
        XCTAssertEqual(sut.myPlayingShowsViewState, .dataNotFound, "No data should've been found")
    }

    func test_OnPlayingShowCreated_PlayingShowsArrayUpdates() async throws {
        try await testingDatabaseService.logInToLouAccount()

        await sut.getPlayingShows()
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.playingShows.count, 1, "Lou should only be playing 1 show at this point")

        var newShow = TestingConstants.exampleShowForIntegrationTesting
        newShow.bandIds.append(TestingConstants.exampleBandPatheticFallacy.id)
        newShow.participantUids.append(TestingConstants.exampleUserJulian.id)
        newShow.participantUids.append(TestingConstants.exampleUserLou.id)
        self.createdShowId = try testingDatabaseService.createShow(newShow)
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.playingShows.count, 2, "Lou is now playing 2 shows")
        XCTAssertEqual(sut.myPlayingShowsViewState, .dataLoaded, "Data should've been loaded")
    }

    func test_OnGetPlayingShows_PlayingShowsListenerIsNotNil() async {
        await sut.getPlayingShows()

        XCTAssertNotNil(sut.playingShowsListener, "The method should've assigned a value to this property")
    }

    func test_OnRemovePlayingShowsListener_ListenerIsRemoved() async throws {
        try await testingDatabaseService.logInToLouAccount()

        await sut.getPlayingShows()
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.playingShows.count, 1, "Lou should only be playing 1 show")

        var newShow = TestingConstants.exampleShowForIntegrationTesting
        newShow.bandIds.append(TestingConstants.exampleBandPatheticFallacy.id)
        newShow.participantUids.append(TestingConstants.exampleUserJulian.id)
        newShow.participantUids.append(TestingConstants.exampleUserLou.id)

        sut.removePlayingShowsListener()

        self.createdShowId = try testingDatabaseService.createShow(newShow)
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.playingShows.count, 1, "The second show shouldn't have been fetched because the listener was removed")
        XCTAssertEqual(sut.myPlayingShowsViewState, .dataLoaded, "The view state shouldn't have changed")
    }

    func test_OnMyHostedShowsErrorViewState_PropertiesAreSet() {

        sut.myHostedShowsViewState = .error(message: "TEST ERROR MESSAGE")

        XCTAssertTrue(sut.myHostedShowsErrorAlertIsShowing)
        XCTAssertEqual(sut.myHostedShowsErrorAlertText, "TEST ERROR MESSAGE")
    }

    func test_OnMyHostedShowsInvalidViewState_PropertiesAreSet() {

        sut.myHostedShowsViewState = .displayingView

        XCTAssertTrue(sut.myHostedShowsErrorAlertIsShowing)
        XCTAssertEqual(sut.myHostedShowsErrorAlertText, "Invalid ViewState")

    }

    func test_OnPlayingShowsErrorViewState_PropertiesAreSet() {
        sut.myPlayingShowsViewState = .error(message: "TEST ERROR MESSAGE")

        XCTAssertTrue(sut.myPlayingShowsErrorAlertIsShowing)
        XCTAssertEqual(sut.myPlayingShowsErrorAlertText, "TEST ERROR MESSAGE")
    }

    func test_OnMyPlayingShowsInvalidViewState_PropertiesAreSet() {
        sut.myPlayingShowsViewState = .displayingView

        XCTAssertTrue(sut.myPlayingShowsErrorAlertIsShowing)
        XCTAssertEqual(sut.myPlayingShowsErrorAlertText, "Invalid ViewState")

    }
}
