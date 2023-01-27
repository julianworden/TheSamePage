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
    var createdBandId: String?
    let exampleUserLou = TestingConstants.exampleUserLou
    let exampleBandMemberLou = TestingConstants.exampleBandMemberLou
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let exampleBandPatheticFallacy = TestingConstants.exampleBandPatheticFallacy
    let exampleShowParticipantPatheticFallacy = TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDown() async throws {
        if let createdBandId {
            try await testingDatabaseService.deleteBand(with: createdBandId)
            self.createdBandId = nil
        }

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
        XCTAssertFalse(sut.sendShowInviteViewIsShowing)
        XCTAssertFalse(sut.editImageViewIsShowing)
        XCTAssertFalse(sut.addEditBandSheetIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoaded)
    }

    func test_OnInitWithShowParticipant_DefaultValuesAreCorrect() async throws {
            try await testingDatabaseService.logInToJulianAccount()
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
        XCTAssertFalse(sut.sendShowInviteViewIsShowing)
        XCTAssertFalse(sut.editImageViewIsShowing)
        XCTAssertFalse(sut.addEditBandSheetIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertFalse(sut.editImageViewIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
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

    func test_OnCallOnAppearMethods_AllBandDataIsFetched() async throws {
        try await testingDatabaseService.logInToJulianAccount()
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

    func test_OnGetLatestBandData_UpdatedBandIsFetched() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = BandProfileViewModel(band: exampleBandPatheticFallacy)
        try await testingDatabaseService.updateBandName(bandId: exampleBandPatheticFallacy.id, newName: "Path Fall")

        await sut.getLatestBandData()

        XCTAssertEqual(sut.band!.name, "Path Fall")

        try await testingDatabaseService.updateBandName(
            bandId: exampleBandPatheticFallacy.id,
            newName: exampleBandPatheticFallacy.name
        )
    }

    func test_OnDeleteBandImage_BandImageIsDeleted() async throws {
        try await testingDatabaseService.logInToEricAccount()
        var exampleBand = TestingConstants.exampleBandForIntegrationTesting
        self.createdBandId = try await testingDatabaseService.createBandWithProfileImage(exampleBand)
        exampleBand.id = createdBandId!
        let createdBandWithProfileImageUrl = try await testingDatabaseService.getBand(withId: exampleBand.id)
        exampleBand.profileImageUrl = createdBandWithProfileImageUrl.profileImageUrl
        sut = BandProfileViewModel(band: exampleBand)

        await sut.deleteBandImage()
        let createdBandWithNoProfileImage = try await testingDatabaseService.getBand(withId: exampleBand.id)

        do {
            _ = try await testingDatabaseService.imageExists(at: exampleBand.profileImageUrl!)
            XCTFail("The image shouldn't exist, so this method should've thrown an error")
        } catch {
            XCTAssertNotNil(error, "An error should've been thrown")
        }

        XCTAssertNil(createdBandWithNoProfileImage.profileImageUrl, "The band should no longer have a profileImageUrl property")
    }

    func test_OnLeaveBand_UserLeavesBand() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = BandProfileViewModel(band: exampleBandPatheticFallacy)

        await sut.removeBandMemberFromBand(bandMember: TestingConstants.exampleBandMemberLou)
        let patheticFallacyWithoutJulian = try await testingDatabaseService.getBand(withId: exampleBandPatheticFallacy.id)
        let patheticFallacyUpdatedBandMembers = try await testingDatabaseService.getAllBandMembers(
            forBandWithId: exampleBandPatheticFallacy.id
        )
        let dumpweedExtravangaUpdated = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)
        let dumpweedExtravaganzaChatUpdated = try await testingDatabaseService.getChat(forShowWithId: dumpweedExtravaganza.id)

        XCTAssertFalse(patheticFallacyWithoutJulian.memberUids.contains(exampleUserLou.id), "Lou left PF")
        XCTAssertFalse (patheticFallacyUpdatedBandMembers.contains(exampleBandMemberLou), "Lou left PF")
        XCTAssertFalse(dumpweedExtravaganzaChatUpdated.participantUids.contains(exampleUserLou.id), "Lou should no longer be in any chats for shows that PF is playing")
        XCTAssertFalse(dumpweedExtravangaUpdated.participantUids.contains(exampleUserLou.id), "Lou should no longer be a participant in any shows that PF is playing")

        try await testingDatabaseService.restorePatheticFallacy(
            band: exampleBandPatheticFallacy,
            show: dumpweedExtravaganza,
            chat: TestingConstants.exampleChatDumpweedExtravaganza,
            bandMembers: [TestingConstants.exampleBandMemberLou]
        )
    }
}