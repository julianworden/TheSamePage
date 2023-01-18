//
//  SearchViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/15/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class SearchViewModelTests: XCTestCase {
    var sut: SearchViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let eric = TestingConstants.exampleUserEric
    let patheticFallacy = TestingConstants.exampleBandPatheticFallacy
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza

    override func setUpWithError() throws {
        sut = SearchViewModel()
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertTrue(sut.fetchedUsers.isEmpty)
        XCTAssertTrue(sut.fetchedBands.isEmpty)
        XCTAssertTrue(sut.fetchedShows.isEmpty)
        XCTAssertFalse(sut.isSearching)
        XCTAssertTrue(sut.queryText.isEmpty)
        XCTAssertEqual(sut.searchType, .user)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut.viewState = .performingWork

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnClearFetchedResultsArrays_ClearsFetchedUsersArray() async {
        sut.queryText = eric.username
        await sut.fetchUsers()

        sut.clearFetchedResultsArrays()

        XCTAssertTrue(sut.fetchedUsers.isEmpty, "The fetchedUsers array should've been cleared")
    }

    func test_OnClearFetchedResultsArrays_ClearsFetchedBandsArray() async {
        sut.queryText = patheticFallacy.name
        await sut.fetchBands()

        sut.clearFetchedResultsArrays()

        XCTAssertTrue(sut.fetchedBands.isEmpty, "The fetchedBands array should've been cleared")
    }

    func test_OnClearFetchedResultsArrays_ClearsFetchedShowsArray() async {
        sut.queryText = dumpweedExtravaganza.name
        await sut.fetchBands()

        sut.clearFetchedResultsArrays()

        XCTAssertTrue(sut.fetchedShows.isEmpty, "The fetchedShows array should've been cleared")
    }

    func test_SearchBarPrompt_ReturnsCorrectValueForUserSearch() {
        sut.searchType = .user

        XCTAssertEqual(sut.searchBarPrompt, "Search by username")
    }

    func test_SearchBarPrompt_ReturnsCorrectValueForBandSearch() {
        sut.searchType = .band

        XCTAssertEqual(sut.searchBarPrompt, "Search by band name")
    }

    func test_SearchBarPrompt_ReturnsCorrectValueForShowSearch() {
        sut.searchType = .show

        XCTAssertEqual(sut.searchBarPrompt, "Search by show name")
    }

    func test_OnFetchUsersWithResults_UserIsInFetchedUsersArrayAndViewStateIsSet() async {
        sut.queryText = eric.username

        await sut.fetchUsers()

        XCTAssertEqual(sut.fetchedUsers.count, 1, "Eric should've been fetched")
        XCTAssertEqual(sut.fetchedUsers.first!.document!, eric, "Eric should've been fetched")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been loaded")
    }

    func test_OnFetchUsersWithNoResults_NoUsersAreFetchedAndViewStateIsSet() async {
        sut.queryText = "zzz"

        await sut.fetchUsers()

        XCTAssertTrue(sut.fetchedUsers.isEmpty, "Nobody should've been fetched")
        XCTAssertEqual(sut.viewState, .dataNotFound, "Data should've been loaded")
    }

    func test_OnFetchBandsWithResults_BandIsInFetchedBandsArrayAndViewStateIsSet() async {
        sut.queryText = patheticFallacy.name

        await sut.fetchBands()

        XCTAssertEqual(sut.fetchedBands.count, 1, "Pathetic Fallacy should've been fetched")
        XCTAssertEqual(sut.fetchedBands.first!.document!, patheticFallacy, "Pathetic Fallacy should've been fetched")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been loaded")
    }

    func test_OnFetchBandsWithNoResults_NoBandsAreFetchedAndViewStateIsSet() async {
        sut.queryText = "zzz"

        await sut.fetchBands()

        XCTAssertTrue(sut.fetchedBands.isEmpty, "No bands should've been fetched")
        XCTAssertEqual(sut.viewState, .dataNotFound, "Data should've been loaded")
    }

    func test_OnFetchShowsWithResults_ShowIsInFetchedShowsArrayAndViewStateIsSet() async {
        sut.queryText = dumpweedExtravaganza.name

        await sut.fetchShows()

        XCTAssertEqual(sut.fetchedShows.count, 1, "Dumpweed Extravaganza should've been fetched")
        XCTAssertEqual(sut.fetchedShows.first!.document!, dumpweedExtravaganza, "Dumpweed Extravaganza should've been fetched")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been loaded")
    }

    func test_OnFetchShowsWithNoResults_NoShowsAreFetchedAndViewStateIsSet() async {
        sut.queryText = "zzzz"

        await sut.fetchShows()

        XCTAssertTrue(sut.fetchedShows.isEmpty, "No shows should've been fetched")
        XCTAssertEqual(sut.viewState, .dataNotFound, "Data should've been loaded")
    }
}
