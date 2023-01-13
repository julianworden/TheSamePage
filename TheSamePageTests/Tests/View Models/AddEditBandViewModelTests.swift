//
//  AddEditBandViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/9/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class AddEditBandViewModelTests: XCTestCase {
    var sut: AddEditBandViewModel!
    var testingDatabaseService: TestingDatabaseService!
    /// Makes it easier to delete an example band that's created for testing in tearDown method. Any band
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdBandDocumentId: String?
    /// Makes it easier to delete an example band image that's created for testing in tearDown method. Any band
    /// image that's created in these tests should assign its download URL to this property so that it can be deleted
    /// during tearDown.
    var createdBandImageDownloadUrl: String?
    /// Makes it easier to delete an example band member image that's created for testing in tearDown method. Any band
    /// member that's created in these tests should assign its document ID to this property so that it can be deleted
    /// during tearDown.
    var createdBandMemberDocumentId: String?

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToEricAccount()
    }

    override func tearDown() async throws {
        if let createdBandMemberDocumentId {
            try await testingDatabaseService.deleteBandMember(in: createdBandDocumentId!, with: createdBandMemberDocumentId)
            self.createdBandMemberDocumentId = nil
        }

        if let createdBandDocumentId {
            try await testingDatabaseService.deleteBand(with: createdBandDocumentId)
            self.createdBandDocumentId = nil
        }

        if let createdBandImageDownloadUrl {
            try await testingDatabaseService.deleteImage(at: createdBandImageDownloadUrl)
            self.createdBandImageDownloadUrl = nil
        }

        try testingDatabaseService.logOut()
        testingDatabaseService = nil
        sut = nil
    }

    func test_OnInitWithNoBandToEditAndUserIsNotOnboarding_DefaultValuesAreCorrect() {
        sut = AddEditBandViewModel(userIsOnboarding: false)

        XCTAssertTrue(sut.bandName.isEmpty)
        XCTAssertTrue(sut.bandBio.isEmpty)
        XCTAssertEqual(sut.bandGenre, .alternative)
        XCTAssertTrue(sut.bandCity.isEmpty)
        XCTAssertEqual(sut.bandState, .AL)
        XCTAssertFalse(sut.userPlaysInBand)
        XCTAssertEqual(sut.userRoleInBand, .vocals)
        XCTAssertFalse(sut.imagePickerIsShowing)
        XCTAssertFalse(sut.bandCreationButtonIsDisabled)
        XCTAssertFalse(sut.userIsOnboarding)
        XCTAssertFalse(sut.dismissView)
        XCTAssertNil(sut.selectedImage)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoaded)
        XCTAssertNil(sut.bandToEdit)
    }

    func test_OnInitWithBandToEditAndUserIsOnboarding_DefaultValuesAreCorrect() {
        let bandToEdit = TestingConstants.exampleBandForIntegrationTesting
        sut = AddEditBandViewModel(
            bandToEdit: bandToEdit,
            userIsOnboarding: true
        )

        XCTAssertEqual(sut.bandName, bandToEdit.name)
        XCTAssertEqual(sut.bandBio, bandToEdit.bio)
        XCTAssertEqual(sut.bandGenre.rawValue, bandToEdit.genre)
        XCTAssertEqual(sut.bandCity, bandToEdit.city)
        XCTAssertEqual(sut.bandState.rawValue, bandToEdit.state)
        XCTAssertFalse(sut.userPlaysInBand)
        XCTAssertEqual(sut.userRoleInBand, .vocals)
        XCTAssertFalse(sut.imagePickerIsShowing)
        XCTAssertFalse(sut.bandCreationButtonIsDisabled)
        XCTAssertTrue(sut.userIsOnboarding)
        XCTAssertFalse(sut.dismissView)
        XCTAssertNil(sut.selectedImage)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .dataLoaded)
        XCTAssertEqual(sut.bandToEdit, bandToEdit)
    }

    // TODO: Add form validation tests when that's added

    func test_OnCreateUpdateBandButtonTappedWithNoBandToEditAndUserNotInBandAndNoImage_BandIsCreated() async throws {
        sut = AddEditBandViewModel(bandToEdit: TestingConstants.exampleBandForIntegrationTesting, userIsOnboarding: false)
        sut.bandToEdit = nil

        guard let createdBandDocumentId = await sut.createUpdateBandButtonTapped() else {
            XCTFail("A document ID should've been created and fetched for the new band")
            return
        }
        self.createdBandDocumentId = createdBandDocumentId
        let createdBand = try await testingDatabaseService.getBand(with: createdBandDocumentId)

        XCTAssertEqual(createdBand.id, createdBandDocumentId, "The document IDs should match")
        XCTAssertEqual(createdBand.name, TestingConstants.exampleBandForIntegrationTesting.name)
        XCTAssertEqual(sut.viewState, .workCompleted, ".workCompleted should be the viewState after a show is created")
    }

    func test_OnCreateUpdateBandButtonTappedWithNoBandToEditAndUserNotInBandAndWithImage_BandAndImageAreCreated() async throws {
        sut = AddEditBandViewModel(bandToEdit: TestingConstants.exampleBandForIntegrationTesting, userIsOnboarding: false)
        sut.bandToEdit = nil
        sut.selectedImage = TestingConstants.uiImageForTesting

        guard let createdBandDocumentId = await sut.createUpdateBandButtonTapped() else {
            XCTFail("A document ID should've been created and fetched for the new band")
            return
        }
        let createdBand = try await testingDatabaseService.getBand(with: createdBandDocumentId)
        let bandImageExists = try await testingDatabaseService.imageExists(at: createdBand.profileImageUrl)
        self.createdBandDocumentId = createdBandDocumentId
        self.createdBandImageDownloadUrl = createdBand.profileImageUrl

        XCTAssertEqual(createdBand.id, createdBandDocumentId, "The document IDs should match")
        XCTAssertTrue(bandImageExists, "The selectedImage's download URL should've been added to the band")
        XCTAssertEqual(createdBand.name, TestingConstants.exampleBandForIntegrationTesting.name, "The wrong bands are being compared")
        XCTAssertEqual(sut.viewState, .workCompleted, ".workCompleted should be the viewState after a show is created")
    }

    func test_OnCreateUpdateBandButtonTappedWithNoBandToEditAndUserIsInBand_BandIsCreatedAndUserIsAddedToBand() async throws {
        sut = AddEditBandViewModel(bandToEdit: TestingConstants.exampleBandForIntegrationTesting, userIsOnboarding: false)
        sut.bandToEdit = nil
        sut.userPlaysInBand = true
        sut.userRoleInBand = .drums

        guard let createdBandDocumentId = await sut.createUpdateBandButtonTapped() else {
            XCTFail("A document ID should've been created and fetched for the new band")
            return
        }
        let createdBand = try await testingDatabaseService.getBand(with: createdBandDocumentId)
        let createdBandMember = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleUserEric.fullName,
            inBandWithId: createdBand.id
        )
        self.createdBandDocumentId = createdBandDocumentId
        self.createdBandMemberDocumentId = createdBandMember.id

        XCTAssertEqual(createdBandMember.fullName, TestingConstants.exampleUserEric.fullName, "Eric should be the band member since he was signed in")
        XCTAssertEqual(createdBandMember.uid, TestingConstants.exampleUserEric.id, "Eric should be the band Member since he was signed in")
        XCTAssertEqual(createdBandMember.role, sut.userRoleInBand.rawValue, "Eric's role should match what was set in the sut")
        XCTAssertEqual(createdBand.memberUids, [TestingConstants.exampleUserEric.id], "Eric's UID should be in the array since he's signed in")
        XCTAssertEqual(createdBand.memberUids.count, 1, "Eric should've been the only member to get added to the band")
        XCTAssertEqual(createdBand.name, TestingConstants.exampleBandForIntegrationTesting.name, "The wrong bands are being compared")
        XCTAssertEqual(sut.viewState, .workCompleted, ".workCompleted should be the viewState after a show is created")
    }

    func test_OnCreateUpdateBandButtonTappedWithBandToEdit_BandIsUpdated() async throws {
        self.createdBandDocumentId = try await testingDatabaseService.createBand(TestingConstants.exampleBandForIntegrationTesting)
        var bandToEdit = TestingConstants.exampleBandForIntegrationTesting
        bandToEdit.id = createdBandDocumentId!
        sut = AddEditBandViewModel(bandToEdit: bandToEdit, userIsOnboarding: false)

        sut.bandName = "TEST BAND NAME UPDATED"
        await sut.createUpdateBandButtonTapped()
        let updatedBand = try await testingDatabaseService.getBand(with: createdBandDocumentId!)

        XCTAssertEqual(bandToEdit.id, updatedBand.id, "The document IDs should match")
        XCTAssertEqual(updatedBand.name, "TEST BAND NAME UPDATED", "The band's name should've been updated")
        XCTAssertEqual(sut.viewState, .workCompleted, ".workCompleted should be the viewState after a show is created")
    }

    func test_OnPerformingWorkViewState_ExpectedWorkIsPerformed() async throws {
        sut = AddEditBandViewModel(userIsOnboarding: false)

        sut.viewState = .performingWork

        XCTAssertTrue(sut.bandCreationButtonIsDisabled, "The button should be disabled while work is being performed")
    }

    func test_OnWorkCompletedViewStateWhenUserIsOnboarding_ExpectedWorkIsPerformed() async throws {
        sut = AddEditBandViewModel(userIsOnboarding: true)

        sut.viewState = .workCompleted

        XCTAssertFalse(sut.userIsOnboarding, "Onboarding should end if the user is onboarding they successfully create a band")
    }

    func test_OnWorkCompletedViewStateWhenUserIsNotOnboarding_ExpectedWorkIsPerformed() async throws {
        sut = AddEditBandViewModel(userIsOnboarding: false)

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.dismissView, "The view should be dismissed if the user is not onboarding and the band is successfully created")
    }
}
