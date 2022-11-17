//
//  AddEditShowViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 11/15/22.
//

@testable import TheSamePage
import CoreLocation
import UIKit.UIImage
import XCTest

final class AddEditShowViewModelTests: XCTestCase {
    var sut: AddEditShowViewModel!
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_WhenShowToEditIsNotNil_PropertiesArePopulated() throws {
        let showToEdit = Show.example
        sut = AddEditShowViewModel(showToEdit: showToEdit)
        
        XCTAssertEqual(sut.showDescription, showToEdit.description)
        XCTAssertEqual(sut.showName, showToEdit.name)
        XCTAssertEqual(sut.showVenue, showToEdit.venue)
        XCTAssertEqual(sut.showHostName, showToEdit.host)
        XCTAssertEqual(sut.showGenre, Genre(rawValue: showToEdit.genre)!)
        XCTAssertEqual(sut.showMaxNumberOfBands, showToEdit.maxNumberOfBands)
        XCTAssertEqual(sut.showDate, Date(timeIntervalSince1970: showToEdit.date))
        XCTAssertEqual(sut.addressIsPrivate, showToEdit.addressIsPrivate)
        XCTAssertEqual(sut.showAddress, showToEdit.address)
        XCTAssertEqual(sut.showCity, showToEdit.city)
        XCTAssertEqual(sut.showState, showToEdit.state)
        XCTAssertEqual(sut.showLatitude, showToEdit.latitude)
        XCTAssertEqual(sut.showLongitude, showToEdit.longitude)
        XCTAssertEqual(sut.showTypesenseCoordinates, showToEdit.typesenseCoordinates)
        XCTAssertEqual(sut.bandIds, showToEdit.bandIds)
        XCTAssertEqual(sut.participantUids, showToEdit.participantUids)
        XCTAssertEqual(sut.showIsFree, showToEdit.isFree)
        XCTAssertEqual(sut.ticketPrice, String(showToEdit.ticketPrice!))
        XCTAssertEqual(sut.ticketSalesAreRequired, showToEdit.ticketSalesAreRequired)
        XCTAssertEqual(sut.minimumRequiredTicketsSold, String(showToEdit.minimumRequiredTicketsSold!))
        XCTAssertEqual(sut.showIs21Plus, showToEdit.is21Plus)
        XCTAssertEqual(sut.showHasBar, showToEdit.hasBar)
        XCTAssertEqual(sut.showHasFood, showToEdit.hasFood)
    }
    
    func test_WithEmptyField_FormIsCompleteIsFalseWhenShowIsFree() throws {
        sut = AddEditShowViewModel()
        
        sut.showIsFree = true
        sut.showName = "   "
        sut.showVenue = "Starland Ballroom"
        sut.showHostName = "Julian Worden"
        sut.showAddress = "Sayreville, New Jersey"
        
        XCTAssertFalse(sut.formIsComplete)
    }
    
    func test_WithEmptyField_FormIsCompleteIsFalseWhenShowIsNotFree() throws {
        sut = AddEditShowViewModel()
        
        sut.showIsFree = false
        sut.showName = "   "
        sut.showVenue = "Starland Ballroom"
        sut.showHostName = "Julian Worden"
        sut.showAddress = "Sayreville, New Jersey"
        sut.ticketPrice = "5"
        
        XCTAssertFalse(sut.formIsComplete)
    }
    
    func test_WithEmptyField_FormIsCompleteIsTrueWhenShowIsNotFree() throws {
        sut = AddEditShowViewModel()
        
        sut.showIsFree = false
        sut.showName = "Great Show Name"
        sut.showVenue = "Starland Ballroom"
        sut.showHostName = "Julian Worden"
        sut.ticketPrice = "5"
        sut.showAddress = "Sayreville, New Jersey"
        
        XCTAssertTrue(sut.formIsComplete)
    }
    
    func test_WithEmptyField_FormIsCompleteIsTrueWhenShowIsFree() throws {
        sut = AddEditShowViewModel()
        
        sut.showIsFree = true
        sut.showName = "Great Show Name"
        sut.showVenue = "Starland Ballroom"
        sut.showHostName = "Julian Worden"
        sut.showAddress = "Sayreville, New Jersey"
        
        XCTAssertTrue(sut.formIsComplete)
    }
    
    func test_OnAddressSearch_ResultsAreReturned() async throws {
        sut = AddEditShowViewModel()
        
        try await sut.search(withText: "Starland Ballroom")
        try await Task.sleep(seconds: 3.0)
        
        XCTAssertTrue(!sut.addressSearchResults.isEmpty)
    }
    
    func test_OnEmptyAddressSearch_ResultsAreNotReturned() async throws {
        sut = AddEditShowViewModel()
        
        try await sut.search(withText: "")
        try await Task.sleep(seconds: 3.0)
        
        XCTAssertTrue(sut.addressSearchResults.isEmpty, "Results are \(sut.addressSearchResults)")
    }
    
    func test_OnShowAddressSelection_LocationPropertiesAreSet() async throws {
        sut = AddEditShowViewModel()
        
        try await sut.search(withText: "Starland Ballroom")
        try await Task.sleep(seconds: 3.0)
        
        XCTAssertTrue(!sut.addressSearchResults.isEmpty)
        
        let addressSearchResult = sut.addressSearchResults[0]
        sut.setShowLocationInfo(withPlacemark: addressSearchResult)
        
        XCTAssertEqual(sut.showLatitude, addressSearchResult.location?.coordinate.latitude)
        XCTAssertEqual(sut.showLongitude, addressSearchResult.location?.coordinate.longitude)
        XCTAssertEqual(
            sut.showTypesenseCoordinates,
            [
                addressSearchResult.location?.coordinate.latitude,
                addressSearchResult.location?.coordinate.longitude
            ]
        )
        XCTAssertEqual(sut.showAddress, addressSearchResult.formattedAddress)
        XCTAssertEqual(sut.showCity, addressSearchResult.postalAddress?.city)
        XCTAssertEqual(sut.showState, addressSearchResult.postalAddress?.state)
    }
    
    func test_CreateShowWithImage_SuccessfullyCreatesShowAndImage() async throws {
        let newShow = Show.example
        sut = AddEditShowViewModel(showToEdit: newShow)
        
        let showImage = UIImage(systemName: "gear")
        let createdShowId = try await sut.createShow(withImage: showImage)
        
        let showExists = try await TestingDatabaseService.shared.showExists(showId: createdShowId)
        let showProfileImageUrl = try await TestingDatabaseService.shared.getImageUrl(showId: createdShowId)

        let showProfilePictureExists = try await DatabaseService.shared.showProfilePictureExists(showImageUrl: showProfileImageUrl)
        
        XCTAssertTrue(showExists)
        XCTAssertTrue(showProfilePictureExists)
        
        if let showProfileImageUrl {
            try await DatabaseService.shared.deleteImage(at: showProfileImageUrl)
        }
        
        try await TestingDatabaseService.shared.deleteShowObject(showId: createdShowId)
    }
    
    func test_CreateShowWithNoImage_SuccessfullyCreatesShow() async throws {
        let newShow = Show.example
        sut = AddEditShowViewModel(showToEdit: newShow)

        let createdShowId = try await sut.createShow(withImage: nil)

        let showExists = try await TestingDatabaseService.shared.showExists(showId: createdShowId)

        XCTAssertTrue(showExists)

        try await TestingDatabaseService.shared.deleteShowObject(showId: createdShowId)
    }
    
    func test_AddressExplanationMessage_ReturnsCorrectStringWithPrivateAddress() throws {
        sut = AddEditShowViewModel()
        sut.addressIsPrivate = true
        
        XCTAssertEqual(sut.publiclyVisibleAddressExplanation, "Anybody can see this show's address")
    }
    
    func test_AddressExplanationMessage_ReturnsCorrectStringWithPublicAddress() throws {
        sut = AddEditShowViewModel()
        sut.addressIsPrivate = false
        
        XCTAssertEqual(sut.publiclyVisibleAddressExplanation, "Anybody can see this show's city and state, but only this show's participants can see the full address")
    }
    
    func test_UpdateShow_SuccessfullyUpdatesShow() async throws {
        var newShow = Show.example
        sut = AddEditShowViewModel(showToEdit: newShow)
        
        let createdShowId = try await sut.createShow()
        let showExists = try await TestingDatabaseService.shared.showExists(showId: createdShowId)
        
        XCTAssertTrue(showExists)
        
        newShow.id = createdShowId
        sut.showToEdit = newShow
        sut.showName = "Big Bonanza"
        
        try await sut.updateShow()
        let updatedShowName = try await TestingDatabaseService.shared.getShowName(showId: createdShowId)
        
        XCTAssertEqual("Big Bonanza", updatedShowName)
        
        try await TestingDatabaseService.shared.deleteShowObject(showId: createdShowId)
    }
    
    func test_UpdateShowWithIncompleteForm_ThrowsError() async throws {
        sut = AddEditShowViewModel()
        let expectation = XCTestExpectation(description: "Call to function should throw an error.")
        
        do {
            try await sut.updateShow()
        } catch {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_IncrementMaxNumberOfBands_IncrementsMaxNumberOfBands() throws {
        let testShow = Show.example
        let sut = AddEditShowViewModel(showToEdit: testShow)
        sut.incrementMaxNumberOfBands()
        
        XCTAssertEqual(testShow.maxNumberOfBands + 1, sut.showMaxNumberOfBands)
    }
    
    func test_DecrementMaxNumberOfBands_DecrementsMaxNumberOfBands() throws {
        let testShow = Show.example
        let sut = AddEditShowViewModel(showToEdit: testShow)
        sut.decrementMaxNumberOfBands()
        
        XCTAssertEqual(testShow.maxNumberOfBands - 1, sut.showMaxNumberOfBands)
    }
    
    func test_DecrementMaxNumberOfBands_DoesNotDecrementMaxNumberOfBands() throws {
        let sut = AddEditShowViewModel()
        sut.showMaxNumberOfBands = -200
        sut.decrementMaxNumberOfBands()
        
        XCTAssertEqual(-200, sut.showMaxNumberOfBands)
    }
    
    func test_IncrementMaxNumberOfBands_DoesNotIncrementMaxNumberOfBands() throws {
        let sut = AddEditShowViewModel()
        sut.showMaxNumberOfBands = 200
        sut.incrementMaxNumberOfBands()
        
        XCTAssertEqual(200, sut.showMaxNumberOfBands)
    }
}
