//
//  BandProfileViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/14/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class BandProfileViewModelTests: XCTestCase {
    var sut: BandProfileViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let exampleBandPatheticFallacy = TestingConstants.exampleBandPatheticFallacy
    let exampleShowParticipantPatheticFallacy = TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInitWithBand_DefaultValuesAreCorrect() async throws {
        sut = BandProfileViewModel(band: exampleBandPatheticFallacy)

        XCTAssertEqual(sut.band, exampleBandPatheticFallacy)
        XCTAssertTrue(sut.bandLinks.isEmpty)
        XCTAssertTrue(sut.bandMembers.isEmpty)
        XCTAssertTrue(sut.bandShows.isEmpty)
        XCTAssertEqual(sut.selectedTab, .about)
        XCTAssertFalse(sut.addEditLinkSheetIsShowing)
        XCTAssertFalse(sut.addBandMemberSheetIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertNil(sut.bandListener)
        XCTAssertEqual(sut.viewState, .dataLoaded)
    }

    func test_OnInitWithShowParticipant_DefaultValuesAreCorrect() async throws {
        sut = BandProfileViewModel(showParticipant: exampleShowParticipantPatheticFallacy)
        try await Task.sleep(seconds: 0.5)

        let bandPredicate = NSPredicate { _, _ in
            (self.sut.band) != nil
        }
        let bandExpectation = XCTNSPredicateExpectation(predicate: bandPredicate, object: nil)

        wait(for: [bandExpectation], timeout: 5)
        XCTAssertEqual(sut.band, exampleBandPatheticFallacy)
        XCTAssertTrue(sut.bandLinks.isEmpty)
        XCTAssertTrue(sut.bandMembers.isEmpty)
        XCTAssertTrue(sut.bandShows.isEmpty)
        XCTAssertEqual(sut.selectedTab, .about)
        XCTAssertFalse(sut.addEditLinkSheetIsShowing)
        XCTAssertFalse(sut.addBandMemberSheetIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertNil(sut.bandListener)
        XCTAssertEqual(sut.viewState, .dataLoaded)
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = BandProfileViewModel()
        
        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut = BandProfileViewModel()

        sut.viewState = .displayingView

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnCallOnAppearMethods_AllBandDataIsFetched() async {
        sut = BandProfileViewModel(band: exampleBandPatheticFallacy)

        await sut.callOnAppearMethods()

        XCTAssertEqual(sut.bandLinks.count, 2, "Pathetic Fallacy should have 2 links")
        XCTAssertTrue(sut.bandLinks.contains(TestingConstants.examplePlatformLinkPatheticFallacyFacebook))
        XCTAssertTrue(sut.bandLinks.contains(TestingConstants.examplePlatformLinkPatheticFallacyInstagram))
        XCTAssertEqual(sut.bandMembers.count, 2, "Lou and Julian are the two Pathetic Fallacy members")
        XCTAssertTrue(sut.bandMembers.contains(TestingConstants.exampleBandMemberLou))
        XCTAssertTrue(sut.bandMembers.contains(TestingConstants.exampleBandMemberJulian))
        XCTAssertEqual(sut.bandShows.count, 1, "Pathetic Fallacy is playing one show")
        XCTAssertEqual(sut.bandShows.first!, TestingConstants.exampleShowDumpweedExtravaganza)
    }

    func test_OnUpdateBandInfo_ListenerUpdatesBandInRealtime() async throws {
        sut = BandProfileViewModel(band: exampleBandPatheticFallacy)
        sut.addBandListener()

        try await testingDatabaseService.updateBandName(bandId: exampleBandPatheticFallacy.id, newName: "Path Fall")
        let updatedPatheticFallacy = try await testingDatabaseService.getBand(withId: exampleBandPatheticFallacy.id)

        XCTAssertEqual(updatedPatheticFallacy.name, "Path Fall", "The name wasn't successfully updated")
        XCTAssertEqual(sut.band!.name, "Path Fall", "The listener should've updated the band's name automatically")
        XCTAssertEqual(updatedPatheticFallacy.name, sut.band!.name, "The listener should've updated the band's name automatically")

        try await testingDatabaseService.updateBandName(bandId: exampleBandPatheticFallacy.id, newName: "Pathetic Fallacy")
    }
}
