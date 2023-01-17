//
//  EditImageViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/10/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class EditImageViewModelTests: XCTestCase {
    var sut: EditImageViewModel!
    var testingDatabaseService: TestingDatabaseService!
    /// Makes it easier to delete an example user that's created for testing in tearDown method. Any user
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdUserUid: String?
    /// Makes it easier to delete an example band that's created for testing in tearDown method. Any band
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdBandId: String?
    /// Makes it easier to delete an example show that's created for testing in tearDown method. Any show
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdShowId: String?
    /// Makes it easier to delete an example image that's created for testing in tearDown method. Any
    /// image that's created in these tests should assign its download URL to this property so that it can be deleted
    /// during tearDown.
    var createdImageUrl: String?

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToExampleAccountForIntegrationTesting()
    }

    override func tearDown() async throws {
        if let createdUserUid {
            try await testingDatabaseService.deleteUserFromFirestore(withUid: createdUserUid)
            self.createdUserUid = nil
        }

        if let createdBandId {
            try await testingDatabaseService.deleteBand(with: createdBandId)
            self.createdBandId = nil
        }

        if let createdShowId {
            try await testingDatabaseService.deleteShow(withId: createdShowId)
            self.createdShowId = nil
        }

        if let createdImageUrl {
            try await testingDatabaseService.deleteImage(at: createdImageUrl)
            self.createdImageUrl = nil
        }

        try testingDatabaseService.logOut()
        testingDatabaseService = nil
        sut = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        sut = EditImageViewModel()

        XCTAssertFalse(sut.imagePickerIsShowing)
        XCTAssertFalse(sut.editButtonIsDisabled)
        XCTAssertFalse(sut.imageUpdateIsComplete)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnInitWithAllInitValues_OnlyShowIsAssigned() {
        let patheticFallacy = TestingConstants.exampleBandPatheticFallacy
        let julian = TestingConstants.exampleUserJulian
        let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza

        sut = EditImageViewModel(show: dumpweedExtravaganza, user: julian, band: patheticFallacy)

        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertNotNil(sut.show)
        XCTAssertNil(sut.band, "The initializer should've returned after initializing the show")
        XCTAssertNil(sut.user, "The initializer should've returned after initializing the show")
    }

    func test_OnInitWithUserAndBand_OnlyUserIsAssigned() {
        let patheticFallacy = TestingConstants.exampleBandPatheticFallacy
        let julian = TestingConstants.exampleUserJulian

        sut = EditImageViewModel(user: julian, band: patheticFallacy)

        XCTAssertNil(sut.show)
        XCTAssertNil(sut.band, "The initializer should've returned after initializing the show")
        XCTAssertNotNil(sut.user)
        XCTAssertEqual(sut.user, julian)
    }

    func test_OnInitWithOnlyBand_BandIsAssigned() {
        let patheticFallacy = TestingConstants.exampleBandPatheticFallacy

        sut = EditImageViewModel(band: patheticFallacy)

        XCTAssertNil(sut.show)
        XCTAssertNil(sut.user)
        XCTAssertNotNil(sut.band)
        XCTAssertEqual(sut.band, patheticFallacy)
    }

    func test_OnEditUserProfileImage_ImageIsEditedAndOldImageIsDeleted() async throws  {
        var exampleUser = TestingConstants.exampleUserForIntegrationTesting
        self.createdUserUid = try await testingDatabaseService.createExampleUserWithProfileImageInFirestore(
            withUser: exampleUser
        )
        exampleUser.id = createdUserUid!
        let createdUserWithOldProfileImageUrl = try await testingDatabaseService.getUserFromFirestore(withUid: exampleUser.id)
        exampleUser.profileImageUrl = createdUserWithOldProfileImageUrl.profileImageUrl
        sut = EditImageViewModel(user: exampleUser)

        let oldProfileImageUrl = exampleUser.profileImageUrl!
        let newProfileImageUrl = await sut.updateImage(withImage: TestingConstants.uiImageForTesting!)
        let createdUserWithNewProfileImageUrl = try await testingDatabaseService.getUserFromFirestore(withUid: exampleUser.id)
        self.createdImageUrl = newProfileImageUrl

        XCTAssertNotEqual(oldProfileImageUrl, newProfileImageUrl, "The user should now have a different profile image URL")
        XCTAssertEqual(newProfileImageUrl, createdUserWithNewProfileImageUrl.profileImageUrl, "The user's profile image URL should've been updated")
        XCTAssertEqual(sut.viewState, .workCompleted)
    }

    func test_OnEditBandProfileImage_ImageIsEditedAndOldImageIsDeleted() async throws  {
        var exampleBand = TestingConstants.exampleBandForIntegrationTesting
        self.createdBandId = try await testingDatabaseService.createBandWithProfileImage(exampleBand)
        exampleBand.id = createdBandId!
        let createdBandWithOldProfileImageUrl = try await testingDatabaseService.getBand(withId: exampleBand.id)
        exampleBand.profileImageUrl = createdBandWithOldProfileImageUrl.profileImageUrl
        sut = EditImageViewModel(band: exampleBand)

        let oldProfileImageUrl = exampleBand.profileImageUrl!
        let newProfileImageUrl = await sut.updateImage(withImage: TestingConstants.uiImageForTesting!)
        let createdBandWithNewProfileImageUrl = try await testingDatabaseService.getBand(withId: exampleBand.id)
        self.createdImageUrl = newProfileImageUrl

        XCTAssertNotEqual(oldProfileImageUrl, newProfileImageUrl, "The band should now have a different profile image URL")
        XCTAssertEqual(newProfileImageUrl, createdBandWithNewProfileImageUrl.profileImageUrl, "The band's profile image URL should've been updated")
        XCTAssertEqual(sut.viewState, .workCompleted)
    }

    func test_OnEditShowImageImage_ImageIsEditedAndOldImageIsDeleted() async throws  {
        var exampleShow = TestingConstants.exampleShowForIntegrationTesting
        self.createdShowId = try await testingDatabaseService.createShowWithImage(exampleShow)
        exampleShow.id = createdShowId!
        let createdShowWithOldProfileImageUrl = try await testingDatabaseService.getShow(withId: exampleShow.id)
        exampleShow.imageUrl = createdShowWithOldProfileImageUrl.imageUrl
        sut = EditImageViewModel(show: exampleShow)

        let oldImageUrl = exampleShow.imageUrl!
        let newImageUrl = await sut.updateImage(withImage: TestingConstants.uiImageForTesting!)
        let createdShowWithNewImageUrl = try await testingDatabaseService.getShow(withId: exampleShow.id)
        self.createdImageUrl = newImageUrl

        XCTAssertNotEqual(oldImageUrl, newImageUrl, "The show should now have a different profile image URL")
        XCTAssertEqual(newImageUrl, createdShowWithNewImageUrl.imageUrl, "The show's profile image URL should've been updated")
        XCTAssertEqual(sut.viewState, .workCompleted)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut = EditImageViewModel()

        sut.viewState = .performingWork

        XCTAssertTrue(sut.editButtonIsDisabled, "The edit button should be disabled while an image is being updated")
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut = EditImageViewModel()

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.imageUpdateIsComplete, "The view needs to be aware of when the image has finished updating")
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut = EditImageViewModel()

        sut.viewState = .error(message: "TEST ERROR MESSAGE")

        XCTAssertFalse(sut.editButtonIsDisabled, "The user should be able to try again after they see an error")
        XCTAssertEqual(sut.errorAlertText, "TEST ERROR MESSAGE", "The user should see the error message in an alert")
        XCTAssertTrue(sut.errorAlertIsShowing, "The user should see an error alert")
    }
}
