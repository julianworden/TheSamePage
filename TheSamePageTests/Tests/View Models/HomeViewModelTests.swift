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
    var sut: FindShowsViewModel!
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

    func test_OnFetchNearbyShowsWithLocationInNewJersey_ShowIsFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        MockController.setNewJerseyMockLocationControllerValues()
        sut = HomeViewModel()

        await sut.fetchNearbyShows()

        XCTAssertEqual(sut.nearbyShows.count, 1, "There is 1 show that is in New Jersey that should be returned")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been found")
    }

    func test_OnFetchNearbyShowsWithLocationInAlaska_NoShowsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
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
        try await testingDatabaseService.logInToJulianAccount()
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

    func test_OnAddPostUserLocationWasSetNotification_NearbyShowsAreFetched() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = HomeViewModel()
        sut.addLocationNotificationObserver()
        MockController.setNewJerseyMockLocationControllerValues()
        let notificationExpectation = XCTNSNotificationExpectation(name: .userLocationWasSet)

        NotificationCenter.default.post(
            name: .userLocationWasSet,
            object: nil
        )
        try await Task.sleep(seconds: 0.5)
        let predicate = NSPredicate { _,_ in
            !self.sut.nearbyShows.isEmpty
        }
        let showLoadedExpectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)

        wait(for: [notificationExpectation], timeout: 2)
        wait(for: [showLoadedExpectation], timeout: 2)
        XCTAssertEqual(sut.nearbyShows.count, 1, "1 show should be in New Jersey near the user.")
        XCTAssertEqual(sut.nearbyShows.first?.document, TestingConstants.exampleShowDumpweedExtravaganza, "Dumpweed Extravaganza should be the only show near the user.")
    }
}
