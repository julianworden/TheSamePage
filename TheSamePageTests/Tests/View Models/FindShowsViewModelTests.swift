//
//  FindShowsViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/11/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class FindShowsViewModelTests: XCTestCase {
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
        sut = FindShowsViewModel()

        XCTAssertTrue(sut.fetchedShows.isEmpty)
        XCTAssertEqual(sut.searchRadiusInMiles, 25)
        XCTAssertFalse(sut.isSearchingByState)
        XCTAssertFalse(sut.isSearchingByDistance)
        XCTAssertFalse(sut.errorMessageIsShowing)
        XCTAssertTrue(sut.errorMessageText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoading)
    }

    func test_OnErrorViewState_PropertiesAreChanged() {
        sut = FindShowsViewModel()

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertTrue(sut.errorMessageIsShowing)
        XCTAssertEqual(sut.errorMessageText, "TEST ERROR")
    }

    func test_OnInvalidViewState_PropertiesAreChanged() {
        sut = FindShowsViewModel()

        sut.viewState = .displayingView

        XCTAssertTrue(sut.errorMessageIsShowing)
        XCTAssertEqual(sut.errorMessageText, "Invalid View State")
    }

    func test_FetchedShowsListHeaderText_ReturnsCorrectValueWhenSearchingByDistance() {
        sut = FindShowsViewModel()
        sut.isSearchingByDistance = true
        sut.searchRadiusInMiles = 25

        XCTAssertEqual(sut.fetchedShowsListHeaderText, "Shows within 25 miles")
    }

    func test_FetchedShowsListHeaderText_ReturnsCorrectValueWhenSearchingByState() {
        sut = FindShowsViewModel()
        sut.isSearchingByState = true
        sut.searchingState = UsState.NJ.rawValue

        XCTAssertEqual(sut.fetchedShowsListHeaderText, "Shows in \(UsState.NJ.rawValue)")
    }

    func test_NoDataFoundText_ReturnsCorrectValueWhenSearchingByDistance() {
        sut = FindShowsViewModel()
        sut.isSearchingByDistance = true
        sut.searchRadiusInMiles = 25

        XCTAssertEqual(sut.noDataFoundText, NoDataFoundConstants.noShowsFoundNearby)
    }

    func test_NoDataFoundText_ReturnsCorrectValueWhenSearchingByState() {
        sut = FindShowsViewModel()
        sut.isSearchingByState = true
        sut.searchingState = UsState.NJ.rawValue

        XCTAssertEqual(sut.noDataFoundText, "We can't find any shows in \(UsState.NJ.rawValue).")
    }

    func test_SearchRadiusInMeters_ReturnsCorrectValue() {
        sut = FindShowsViewModel()

        sut.searchRadiusInMiles = 50

        XCTAssertEqual(sut.searchRadiusInMeters, 80467.2)
    }

    func test_OnFetchNearbyShowsWithLocationInNewJersey_ShowIsFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        MockController.setNewJerseyMockLocationControllerValues()
        sut = FindShowsViewModel()

        await sut.fetchNearbyShows()

        XCTAssertEqual(sut.fetchedShows.count, 1, "There is 1 show that is in New Jersey that should be returned")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been found")
        XCTAssertTrue(sut.isSearchingByDistance)
    }

    func test_OnFetchNearbyShowsWithLocationInAlaska_NoShowsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        MockController.setAlaskaMockLocationControllerValues()
        sut = FindShowsViewModel()

        await sut.fetchNearbyShows()

        XCTAssertTrue(sut.fetchedShows.isEmpty, "There should be no shows within 25 miles of Alaska")
        XCTAssertEqual(sut.viewState, .dataNotFound, "No data should've been found")
        XCTAssertTrue(sut.isSearchingByDistance)
    }

    func test_OnFetchShowsInCa_ShowIsFetched() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = FindShowsViewModel()

        await sut.fetchShows(in: UsState.CA.rawValue)

        XCTAssertEqual(sut.fetchedShows.count, 1)
        XCTAssertEqual(sut.viewState, .dataLoaded)
        XCTAssertTrue(sut.isSearchingByState)
    }

    func test_OnFetchShowsInAz_NoShowsAreFetched() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = FindShowsViewModel()

        await sut.fetchShows(in: UsState.AZ.rawValue)

        XCTAssertTrue(sut.fetchedShows.isEmpty)
        XCTAssertEqual(sut.viewState, .dataNotFound)
        XCTAssertTrue(sut.isSearchingByState)
    }

    func test_OnChangeSearchRadius_SearchIsRetried() async throws {
        // This test fails sometime, likely because TypeSense takes more time to receive updates than Firebase Emulator.
        // This sleep should allow TypeSense to catch up.
        try await Task.sleep(seconds: 1)
        try await testingDatabaseService.logInToJulianAccount()
        sut = FindShowsViewModel()
        MockController.setAlaskaMockLocationControllerValues()

        await sut.fetchNearbyShows()

        XCTAssertTrue(sut.fetchedShows.isEmpty, "There should be no shows within 25 miles of Alaska")
        XCTAssertEqual(sut.viewState, .dataNotFound, "No data should've been found")

        MockController.setNewJerseyMockLocationControllerValues()

        await sut.changeSearchRadius(toValueInMiles: 50)

        XCTAssertEqual(sut.fetchedShows.count, 1, "Now that the location was changed to New Jersey, one show should've been found")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been found")
        XCTAssertEqual(sut.searchRadiusInMiles, 50, "The function call should've changed the searchRadiusInMiles value")
    }

    func test_OnAddPostUserLocationWasSetNotification_NearbyShowsAreFetched() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = FindShowsViewModel()
        sut.addLocationNotificationObserver()
        MockController.setNewJerseyMockLocationControllerValues()
        let notificationExpectation = XCTNSNotificationExpectation(name: .userLocationWasSet)

        NotificationCenter.default.post(
            name: .userLocationWasSet,
            object: nil
        )
        try await Task.sleep(seconds: 0.5)
        let predicate = NSPredicate { _,_ in
            !self.sut.fetchedShows.isEmpty
        }
        let showLoadedExpectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)

        wait(for: [notificationExpectation], timeout: 2)
        wait(for: [showLoadedExpectation], timeout: 2)
        XCTAssertEqual(sut.fetchedShows.count, 1, "1 show should be in New Jersey near the user.")
        XCTAssertEqual(sut.fetchedShows.first?.document, TestingConstants.exampleShowDumpweedExtravaganza, "Dumpweed Extravaganza should be the only show near the user.")
    }
}
