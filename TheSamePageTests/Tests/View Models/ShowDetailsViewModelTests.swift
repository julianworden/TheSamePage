//
//  ShowDetailsViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/16/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class ShowDetailsViewModelTests: XCTestCase {
    var sut: ShowDetailsViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.selectedTab, .details)
        XCTAssertTrue(sut.drumKitBacklineItems.isEmpty)
        XCTAssertTrue(sut.percussionBacklineItems.isEmpty)
        XCTAssertTrue(sut.bassGuitarBacklineItems.isEmpty)
        XCTAssertTrue(sut.electricGuitarBacklineItems.isEmpty)
        XCTAssertNil(sut.showListener)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
    }

    func test_OnCallOnAppearMethods_PropertiesAreSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        await sut.callOnAppearMethods()

        XCTAssertNotNil(sut.showListener)
        XCTAssertEqual(sut.showParticipants.count, 2, "Two bands are playing this show")
    }

    func test_ShowSlotsRemainingMessage_ReturnsCorrectValueWhenShowLineupHasMoreThanOneSlotRemaining() async throws {
        var dumpweedExtravaganzaCopy = dumpweedExtravaganza
        dumpweedExtravaganzaCopy.maxNumberOfBands = 5
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganzaCopy)
        await sut.getShowParticipants()

        XCTAssertEqual(sut.showSlotsRemainingMessage, "3 slots remaining", "There should be 3 slots remaining since the max number of bands is 5 and there are 2 bands playing")
    }

    func test_ShowSlotsRemainingMessage_ReturnsCorrectValueWhenShowLineupHasOneSlotRemaining() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)
        await sut.callOnAppearMethods()

        XCTAssertEqual(sut.showSlotsRemainingMessage, "1 slot remaining", "There should be 1 slot remaining since the max number of bands is 3 and there are 2 bands playing")
    }

    func test_NoShowTimesMessage_ReturnsCorrectValueWhenLoggedInUserIsShowHost() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.noShowTimesMessage, "No times have been added to this show. Use the buttons above to add show times.")
    }

    func test_NoShowTimesMessage_ReturnsCorrectValueWhenLoggedInUserIsNotShowHost() async throws {
        try await testingDatabaseService.logInToLouAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.noShowTimesMessage, "No times have been added to this show. Only the show's host can add times.")
    }

    func test_MapAnnotations_ReturnCorrectValue() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)
        let customMapAnnotation = CustomMapAnnotation(coordinates: dumpweedExtravaganza.coordinates)

        XCTAssertEqual(sut.mapAnnotations.count, 1, "We only need one map annotation for the show")
        XCTAssertEqual(sut.mapAnnotations.first!.coordinate.latitude, customMapAnnotation.coordinate.latitude)
        XCTAssertEqual(sut.mapAnnotations.first!.coordinate.longitude, customMapAnnotation.coordinate.longitude)
    }
}
