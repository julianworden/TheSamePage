//
//  ShowTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/8/23.
//

@testable import TheSamePage

import MapKit
import XCTest

final class ShowTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!
    var exampleShow: Show!

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        // Some tests modify exampleShow's properties, this ensures they're reset
        exampleShow = TestingConstants.exampleShowDumpweedExtravaganza
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
        exampleShow = nil
    }

    func test_FormattedDate_ReturnsCorrectValue() {
        XCTAssertEqual(
            exampleShow.formattedDate,
            Date(timeIntervalSince1970: exampleShow.date).formatted(date: .numeric, time: .omitted)
        )
    }

    func test_FormattedTicketPrice_ReturnsCorrectValueWhenTicketPriceValueExists() {
        XCTAssertNotNil(exampleShow.formattedTicketPrice)
        XCTAssertEqual(
            exampleShow.formattedTicketPrice,
            exampleShow.ticketPrice!.formatted(.currency(code: Locale.current.currencyCode ?? "USD"))
        )
    }

    func test_FormattedTicketPrice_ReturnsNilWhenTicketPriceValueDoesNotExist() {
        exampleShow.ticketPrice = nil

        XCTAssertNil(exampleShow.formattedTicketPrice)
    }

    func test_HasTime_ReturnsTrueWhenOnlyLoadInTimeExists() {
        exampleShow.doorsTime = nil
        exampleShow.musicStartTime = nil
        exampleShow.endTime = nil

        XCTAssertNotNil(exampleShow.loadInTime, "The example show has values for all times by default")
        XCTAssertTrue(exampleShow.hasTime, "Should be true because one time exists")
    }

    func test_HasTime_ReturnsTrueWhenOnlyDoorsTimeExists() {
        exampleShow.loadInTime = nil
        exampleShow.musicStartTime = nil
        exampleShow.endTime = nil

        XCTAssertNotNil(exampleShow.doorsTime, "The example show has values for all times by default")
        XCTAssertTrue(exampleShow.hasTime, "Should be true because one time exists")
    }

    func test_HasTime_ReturnsTrueWhenOnlyMusicStartTimeExists() {
        exampleShow.doorsTime = nil
        exampleShow.loadInTime = nil
        exampleShow.endTime = nil

        XCTAssertNotNil(exampleShow.musicStartTime, "The example show has values for all times by default")
        XCTAssertTrue(exampleShow.hasTime, "Should be true because one time exists")
    }

    func test_HasTime_ReturnsTrueWhenOnlyEndTimeExists() {
        exampleShow.doorsTime = nil
        exampleShow.musicStartTime = nil
        exampleShow.loadInTime = nil

        XCTAssertNotNil(exampleShow.endTime, "The example show has values for all times by default")
        XCTAssertTrue(exampleShow.hasTime, "Should be true because one time exists")
    }

    func test_HasTime_ReturnsFalseWhenNoTimesExists() {
        exampleShow.doorsTime = nil
        exampleShow.musicStartTime = nil
        exampleShow.loadInTime = nil
        exampleShow.endTime = nil

        XCTAssertFalse(exampleShow.hasTime, "The show has no times")
    }

    func test_LoggedInUserIsShowHost_ReturnsTrueWhenLoggedInUserIsShowHost() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertTrue(exampleShow.loggedInUserIsShowHost, "Julian is the host of this show")
    }

    func test_LoggedInUserIsShowHost_ReturnsFalseWhenLoggedInUserIsNotShowHost() async throws {
        try await testingDatabaseService.logInToEricAccount()

        XCTAssertFalse(exampleShow.loggedInUserIsShowHost, "Julian is the host of this show, not Eric")
    }

    func test_LoggedInUserIsShowParticipant_ReturnsTrueWhenLoggedInUserIsShowParticipant() async throws {
        try await testingDatabaseService.logInToLouAccount()

        XCTAssertTrue(exampleShow.loggedInUserIsShowParticipant, "Lou is a participant in this show")
    }

    func test_LoggedInUserIsShowParticipant_ReturnsFalseWhenLoggedInUserIsNotShowParticipant() async throws {
        try await testingDatabaseService.logInToMikeAccount()

        XCTAssertFalse(exampleShow.loggedInUserIsShowParticipant, "Mike is not a participant in this show")
    }

    func test_LoggedInUserIsNotInvolvedInShow_ReturnsTrueWhenUserIsNotHostOrParticipant() async throws {
        try await testingDatabaseService.logInToMikeAccount()

        XCTAssertTrue(exampleShow.loggedInUserIsNotInvolvedInShow, "Mike is not participating in or hosting this show")
    }

    func test_LoggedInUserIsNotInvolvedInShow_ReturnsFalseWhenUserIsShowHost() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertFalse(exampleShow.loggedInUserIsNotInvolvedInShow, "Julian is the show host")
    }

    func test_LoggedInUserIsNotInvolvedInShow_ReturnsFalseWhenUserIsShowParticipant() async throws {
        try await testingDatabaseService.logInToLouAccount()

        XCTAssertFalse(exampleShow.loggedInUserIsNotInvolvedInShow, "Lou is a show participant")
    }

    func test_LoggedInUserIsInvolvedInShow_ReturnsTrueWhenUserIsShowHost() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertTrue(exampleShow.loggedInUserIsInvolvedInShow, "Julian is the show host")
    }

    func test_LoggedInUserIsInvolvedInShow_ReturnsTrueWhenUserIsShowParticipant() async throws {
        try await testingDatabaseService.logInToLouAccount()

        XCTAssertTrue(exampleShow.loggedInUserIsShowParticipant, "Lou is a show participant")
    }

    func test_LoggedInUserIsInvolvedInShow_ReturnsFalseWhenUserIsNotHostOrParticipant() async throws {
        try await testingDatabaseService.logInToMikeAccount()

        XCTAssertFalse(exampleShow.loggedInUserIsShowParticipant, "Mike is not participating in or hosting this show")
    }

    func test_AddressIsVisibleToUser_ReturnsTrueWhenUserIsInvolvedInShowAndAddressIsPrivate() async throws {
        try await testingDatabaseService.logInToLouAccount()
        exampleShow.addressIsPrivate = true

        XCTAssertTrue(exampleShow.addressIsVisibleToUser, "The address should be visible to Lou since he is a show participant")
    }

    func test_AddressIsVisibleToUser_ReturnsTrueWhenUserIsNotInvolvedInShowAndAddressIsNotPrivate() async throws {
        try await testingDatabaseService.logInToMikeAccount()
        exampleShow.addressIsPrivate = false

        XCTAssertTrue(exampleShow.addressIsVisibleToUser, "The address should be visible to Mike since he is not a show participant but the address is not present")
    }

    func test_AddressIsVisibleToUser_ReturnsFalseWhenUserIsNotInvolvedInShowAndAddressIsPrivate() async throws {
        try await testingDatabaseService.logInToMikeAccount()
        exampleShow.addressIsPrivate = true

        XCTAssertFalse(exampleShow.addressIsVisibleToUser, "The address should not be visible to Mike since he is not a participant and the address is private")
    }

    func test_ShouldDisplayIcons_ReturnsTrueWhenShowHasFoodNoBarAndIsNot21Plus() {
        exampleShow.hasFood = true
        exampleShow.hasBar = false
        exampleShow.is21Plus = false

        XCTAssertTrue(exampleShow.shouldDisplayIcons, "An icon should be shown since the show has food")
    }

    func test_ShouldDisplayIcons_ReturnsTrueWhenShowHasNoFoodHasBarAndIsNot21Plus() {
        exampleShow.hasFood = false
        exampleShow.hasBar = true
        exampleShow.is21Plus = false

        XCTAssertTrue(exampleShow.shouldDisplayIcons, "An icon should be shown since the show has a bar")
    }

    func test_ShouldDisplayIcons_ReturnsTrueWhenShowHasNoFoodNoBarAndIs21Plus() {
        exampleShow.hasFood = false
        exampleShow.hasBar = false
        exampleShow.is21Plus = true

        XCTAssertTrue(exampleShow.shouldDisplayIcons, "An icon should be shown since the show is 21+")
    }

    func test_ShouldDisplayIcons_ReturnsFalseWhenShowHasNoFoodNoBarAndIsNot21Plus() {
        exampleShow.hasFood = false
        exampleShow.hasBar = false
        exampleShow.is21Plus = false

        XCTAssertFalse(exampleShow.shouldDisplayIcons, "Food, Bar, and 21+ icons don't need to be shown since the show isn't any of those things")
    }

    func test_DistanceFromUser_ReturnsCorrectValue() {
        MockController.setSanFranciscoMockLocationControllerValues()

        XCTAssertEqual("2,541 miles", exampleShow.distanceFromUser)
    }

    func test_Location_ReturnsCorrectValue() {
        MockController.setSanFranciscoMockLocationControllerValues()
        let mockShowLocation = CLLocation(latitude: exampleShow.latitude, longitude: exampleShow.longitude)

        // Comparing CLLocation values directly doesn't seem to be possible. This is acceptable even though it
        // doesn't compare all CLLocation properties since the app only uses the location information from CLLocation objects
        XCTAssertEqual(
            exampleShow.location.distance(from: LocationController.shared.userLocation!),
            mockShowLocation.distance(from: LocationController.shared.userLocation!)
        )
    }

    func test_Coordinates_ReturnsCorrectValue() {
        let mockShowCoordinates = CLLocationCoordinate2D(latitude: exampleShow.latitude, longitude: exampleShow.longitude)

        XCTAssertEqual(mockShowCoordinates.latitude, exampleShow.coordinates.latitude)
        XCTAssertEqual(mockShowCoordinates.longitude, exampleShow.coordinates.longitude)
    }

    func test_Region_ReturnsCorrectValue() {
        let mockShowRegion = MKCoordinateRegion(center: exampleShow.coordinates, latitudinalMeters: 500, longitudinalMeters: 500)

        XCTAssertEqual(mockShowRegion.center.latitude, exampleShow.region.center.latitude)
        XCTAssertEqual(mockShowRegion.center.longitude, exampleShow.region.center.longitude)
        XCTAssertEqual(mockShowRegion.span.latitudeDelta, exampleShow.region.span.latitudeDelta)
        XCTAssertEqual(mockShowRegion.span.longitudeDelta, exampleShow.region.span.longitudeDelta)
    }

    func test_LineupIsFull_ReturnsTrueWhenLineupIsFull() {
        exampleShow.maxNumberOfBands = 3
        exampleShow.bandIds = [";alskdfja;sldfj", ";alskdfja;sldfj", ";alskdfja;sldfj"]

        XCTAssertTrue(exampleShow.lineupIsFull, "The lineup is full because 3 bands are playing the show and the max number of bands for the show is 3")
    }

    func test_LineupIsFull_ReturnsFalseWhenLineupIsNotFull() {
        exampleShow.maxNumberOfBands = 4
        exampleShow.bandIds = [";alskdfja;sldfj", ";alskdfja;sldfj"]

        XCTAssertFalse(exampleShow.lineupIsFull, "The lineup is not full because 2 bands are playing the show and the max number of bands for the show is 4")
    }
}
