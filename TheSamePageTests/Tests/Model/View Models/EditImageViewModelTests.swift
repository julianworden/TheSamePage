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
    var createdUserUid: String?
    var createdBandId: String?
    var createdShowId: String?
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
            try await testingDatabaseService.deleteShow(with: createdShowId)
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

    // TODO: Add sut default value tests

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
    }

    func test_OnEditBandProfileImage_ImageIsEditedAndOldImageIsDeleted() async throws  {
        var exampleBand = TestingConstants.exampleBandForIntegrationTesting
        self.createdBandId = try await testingDatabaseService.createBandWithProfileImage(exampleBand)
        exampleBand.id = createdBandId!
        let createdBandWithOldProfileImageUrl = try await testingDatabaseService.getBand(with: exampleBand.id)
        exampleBand.profileImageUrl = createdBandWithOldProfileImageUrl.profileImageUrl
        sut = EditImageViewModel(band: exampleBand)

        let oldProfileImageUrl = exampleBand.profileImageUrl!
        let newProfileImageUrl = await sut.updateImage(withImage: TestingConstants.uiImageForTesting!)
        let createdBandWithNewProfileImageUrl = try await testingDatabaseService.getBand(with: exampleBand.id)
        self.createdImageUrl = newProfileImageUrl

        XCTAssertNotEqual(oldProfileImageUrl, newProfileImageUrl, "The band should now have a different profile image URL")
        XCTAssertEqual(newProfileImageUrl, createdBandWithNewProfileImageUrl.profileImageUrl, "The band's profile image URL should've been updated")
    }

    func test_OnEditShowImageImage_ImageIsEditedAndOldImageIsDeleted() async throws  {
        var exampleShow = TestingConstants.exampleShowForIntegrationTesting
        self.createdShowId = try await testingDatabaseService.createShowWithImage(exampleShow)
        exampleShow.id = createdShowId!
        let createdShowWithOldProfileImageUrl = try await testingDatabaseService.getShow(with: exampleShow.id)
        exampleShow.imageUrl = createdShowWithOldProfileImageUrl.imageUrl
        sut = EditImageViewModel(show: exampleShow)

        let oldImageUrl = exampleShow.imageUrl!
        let newImageUrl = await sut.updateImage(withImage: TestingConstants.uiImageForTesting!)
        let createdShowWithNewImageUrl = try await testingDatabaseService.getShow(with: exampleShow.id)
        self.createdImageUrl = newImageUrl

        XCTAssertNotEqual(oldImageUrl, newImageUrl, "The show should now have a different profile image URL")
        XCTAssertEqual(newImageUrl, createdShowWithNewImageUrl.imageUrl, "The show's profile image URL should've been updated")
    }
}
