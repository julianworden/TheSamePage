//
//  HomeViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/11/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var testingDatabaseService: TestingDatabaseService!

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = HomeViewModel()

        XCTAssertTrue(sut.nearbyShows.isEmpty)
        XCTAssertEqual(sut.searchRadiusInMiles, 25)
        XCTAssertFalse(sut.filterConfirmationDialogIsShowing)
        XCTAssertFalse(sut.errorMessageIsShowing)
        XCTAssertTrue(sut.errorMessageText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoading)
    }

    func test_NearbyShowsListHeaderText_ReturnsCorrectValue() {
        sut = HomeViewModel()

        sut.searchRadiusInMiles = 25

        XCTAssertEqual(sut.nearbyShowsListHeaderText, "Shows within 25 miles...")
    }

    func test_SearchRadiusInMeters_ReturnsCorrectValue() {
        sut = HomeViewModel()

        sut.searchRadiusInMiles = 50

        XCTAssertEqual(sut.searchRadiusInMeters, 80467.2)
    }

    func test_OnFetchNearbyShowsWithLocationInNewJersey_ShowIsFetchedAndViewStateIsSet() async {
        MockController.setNewJerseyMockLocationControllerValues()
        sut = HomeViewModel()

        await sut.fetchNearbyShows()

        XCTAssertEqual(sut.nearbyShows.count, 1, "There is 1 show that is in New Jersey that should be returned")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been found")
    }

    func test_OnFetchNearbyShowsWithLocationInAlaska_NoShowsAreFetchedAndViewStateIsSet() async {
        MockController.setAlaskaMockLocationControllerValues()
        sut = HomeViewModel()

        await sut.fetchNearbyShows()

        XCTAssertTrue(sut.nearbyShows.isEmpty, "There should be no shows within 25 miles of Alaska")
        XCTAssertEqual(sut.viewState, .dataNotFound, "No data should've been found")
    }

    func test_OnChangeSearchRadius_SearchIsRetried() async throws {
        // This test fails sometime, likely because TypeSense takes more time to receive updates than Firebase Emulator.
        // This sleep should allow TypeSense to catch up.
        try await Task.sleep(seconds: 1)
        sut = HomeViewModel()
        MockController.setAlaskaMockLocationControllerValues()

        await sut.fetchNearbyShows()

        XCTAssertTrue(sut.nearbyShows.isEmpty, "There should be no shows within 25 miles of Alaska")
        XCTAssertEqual(sut.viewState, .dataNotFound, "No data should've been found")

        MockController.setNewJerseyMockLocationControllerValues()

        await sut.changeSearchRadius(toValueInMiles: 50)

        XCTAssertEqual(sut.nearbyShows.count, 1, "Now that the location was changed to New Jersey, one show should've been found")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been found")
        XCTAssertEqual(sut.searchRadiusInMiles, 50, "The function call should've changed the searchRadiusInMiles value")
    }

    func test_OnErrorViewState_PropertiesAreChanged() {
        sut = HomeViewModel()

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertTrue(sut.errorMessageIsShowing)
        XCTAssertEqual(sut.errorMessageText, "TEST ERROR")
    }

    func test_OnInvalidViewState_PropertiesAreChanged() {
        sut = HomeViewModel()

        sut.viewState = .displayingView

        XCTAssertTrue(sut.errorMessageIsShowing)
        XCTAssertEqual(sut.errorMessageText, "Invalid View State")
    }
}
