//
//  AddEditShowViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 11/15/22.
//

@testable import TheSamePage
import FirebaseCore
import FirebaseFirestore
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
        
        try await sut.search(withText: "Starbucks")
        
        XCTAssertTrue(!sut.addressSearchResults.isEmpty)
    }
}
