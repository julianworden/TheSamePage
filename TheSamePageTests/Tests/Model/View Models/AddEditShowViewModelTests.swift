//
//  AddEditShowViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/8/23.
//

@testable import TheSamePage

import Contacts
import Intents
import XCTest

@MainActor
final class AddEditShowViewModelTests: XCTestCase {
    var sut: AddEditShowViewModel!
    var testingDatabaseService: TestingDatabaseService!
    /// Makes it easier to delete an example show that's created for testing in tearDown method. Any show
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdShowDocumentId: String?
    /// Makes it easier to delete an example show image that's created for testing in tearDown method. Any show
    /// image that's created in these tests should assign its download URL to this property so that it can be deleted
    /// during tearDown.
    var createdShowImageDownloadUrl: String?

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        // Example show is hosted by Eric, so he must be signed in
        try await testingDatabaseService.logInToEricAccount()
    }

    override func tearDown() async throws {
        // Deletes example in the event that it was created by any test
        if let createdShowDocumentId {
            try await testingDatabaseService.deleteShow(with: createdShowDocumentId)
            self.createdShowDocumentId = nil
        }

        if let createdShowImageDownloadUrl {
            try await testingDatabaseService.deleteImage(at: createdShowImageDownloadUrl)
            self.createdShowImageDownloadUrl = nil
        }

        try testingDatabaseService.logOut()
        testingDatabaseService = nil
        sut = nil
    }

    func test_OnInitWithNoShowToEdit_DefaultValuesAreCorrect() {
        sut = AddEditShowViewModel()

        XCTAssertTrue(sut.showName.isEmpty)
        XCTAssertTrue(sut.showDescription.isEmpty)
        XCTAssertTrue(sut.showVenue.isEmpty)
        XCTAssertTrue(sut.showHostName.isEmpty)
        XCTAssertEqual(sut.showGenre, Genre.rock)
        XCTAssertEqual(sut.showMaxNumberOfBands, 1)
        XCTAssertEqual(
            sut.showDate.formatted(date: .complete, time: .complete),
            Date.now.formatted(date: .complete, time: .complete)
        )
        XCTAssertFalse(sut.addressIsPrivate)
        XCTAssertNil(sut.showAddress)
        XCTAssertNil(sut.showCity)
        XCTAssertNil(sut.showState)
        XCTAssertEqual(sut.showLatitude, 0)
        XCTAssertEqual(sut.showLongitude, 0)
        XCTAssertTrue(sut.showTypesenseCoordinates.isEmpty)
        XCTAssertNil(sut.addressSearch)
        XCTAssertTrue(sut.bandIds.isEmpty)
        XCTAssertTrue(sut.participantUids.isEmpty)
        XCTAssertFalse(sut.showIsFree)
        XCTAssertTrue(sut.ticketPrice.isEmpty)
        XCTAssertFalse(sut.ticketSalesAreRequired)
        XCTAssertTrue(sut.minimumRequiredTicketsSold.isEmpty)
        XCTAssertFalse(sut.showIs21Plus)
        XCTAssertFalse(sut.showHasBar)
        XCTAssertFalse(sut.showHasFood)
        XCTAssertFalse(sut.imagePickerIsShowing)
        XCTAssertFalse(sut.bandSearchSheetIsShowing)
        XCTAssertNil(sut.showImage)
        XCTAssertFalse(sut.createShowButtonIsDisabled)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertFalse(sut.showCreatedSuccessfully)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
    }

    func test_OnInitWithShowToEdit_DefaultValuesAreCorrect() {
        let showToEdit = TestingConstants.exampleShowForIntegrationTesting
        sut = AddEditShowViewModel(showToEdit: showToEdit)

        XCTAssertEqual(sut.showName, showToEdit.name)
        XCTAssertEqual(sut.showDescription, showToEdit.description)
        XCTAssertEqual(sut.showVenue, showToEdit.venue)
        XCTAssertEqual(sut.showHostName, showToEdit.host)
        XCTAssertEqual(sut.showGenre, Genre(rawValue: showToEdit.genre))
        XCTAssertEqual(sut.showMaxNumberOfBands, showToEdit.maxNumberOfBands)
        XCTAssertEqual(sut.showDate, Date(timeIntervalSince1970: showToEdit.date))
        XCTAssertEqual(sut.addressIsPrivate, showToEdit.addressIsPrivate)
        XCTAssertEqual(sut.showAddress, showToEdit.address)
        XCTAssertEqual(sut.showCity, showToEdit.city)
        XCTAssertEqual(sut.showState, showToEdit.state)
        XCTAssertEqual(sut.showLatitude, showToEdit.latitude)
        XCTAssertEqual(sut.showLongitude, showToEdit.longitude)
        XCTAssertEqual(sut.showTypesenseCoordinates, showToEdit.typesenseCoordinates)
        XCTAssertNil(sut.addressSearch)
        XCTAssertEqual(sut.bandIds, showToEdit.bandIds)
        XCTAssertEqual(sut.participantUids, showToEdit.participantUids)
        XCTAssertEqual(sut.showIsFree, showToEdit.isFree)
        XCTAssertEqual(Double(sut.ticketPrice), showToEdit.ticketPrice)
        XCTAssertEqual(sut.ticketSalesAreRequired, showToEdit.ticketSalesAreRequired)
        XCTAssertEqual(Int(sut.minimumRequiredTicketsSold), showToEdit.minimumRequiredTicketsSold)
        XCTAssertEqual(sut.showIs21Plus, showToEdit.is21Plus)
        XCTAssertEqual(sut.showHasBar, showToEdit.hasBar)
        XCTAssertEqual(sut.showHasFood, showToEdit.hasFood)
        XCTAssertFalse(sut.imagePickerIsShowing)
        XCTAssertFalse(sut.bandSearchSheetIsShowing)
        XCTAssertNil(sut.showImage)
        XCTAssertFalse(sut.createShowButtonIsDisabled)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertFalse(sut.showCreatedSuccessfully)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
    }

    func test_PubliclyVisibleAddressExplanation_ReturnsCorrectValueWhenAddressIsPrivate() {
        sut = AddEditShowViewModel()
        sut.addressIsPrivate = true

        XCTAssertEqual(sut.publiclyVisibleAddressExplanation, "Anybody can see this show's address")
    }

    func test_PubliclyVisibleAddressExplanation_ReturnsCorrectValueWhenAddressIsNotPrivate() {
        sut = AddEditShowViewModel()
        sut.addressIsPrivate = false

        XCTAssertEqual(sut.publiclyVisibleAddressExplanation, "Anybody can see this show's city and state, but only this show's participants can see the full address")
    }

    func test_FormIsComplete_ReturnsFalseWithNoShowNameWhenShowIsFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = true
        sut.showName = "  "

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNoShowVenueWhenShowIsFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = true
        sut.showVenue = "  "

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNoShowHostWhenShowIsFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = true
        sut.showHostName = "  "

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNilShowAddressWhenShowIsFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = true
        sut.showAddress = nil

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsTrueWithAllRequiredFormFieldsFilledWhenShowIsFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = true

        XCTAssertTrue(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNoShowNameWhenShowIsNotFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = false
        sut.showName = "  "

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNoShowVenueWhenShowIsNotFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = false
        sut.showVenue = "  "

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNoShowHostWhenShowIsNotFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = false
        sut.showHostName = "  "

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNilShowAddressWhenShowIsNotFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = false
        sut.showAddress = nil

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNoTicketPriceWhenShowIsNotFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = false
        sut.ticketPrice = "   "

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsTrueWithAllRequiredFormFieldsFilledWhenShowIsNotFree() {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showIsFree = false

        XCTAssertTrue(sut.formIsComplete)
    }

    func test_OnNotificationIsPostedForShowAddressObserver_ValuesAreAssigned() {
        sut = AddEditShowViewModel()
        sut.addShowAddressObserver()
        let placemarkToBePosted = TestingConstants.getExampleShowDumpweedExtravaganzaPlacemark()
        let placemarkToBePostedLatitude = placemarkToBePosted.location!.coordinate.latitude
        let placemarkToBePostedLongitude = placemarkToBePosted.location!.coordinate.longitude
        let expectation = XCTNSNotificationExpectation(name: .showAddressSelected)

        NotificationCenter.default.post(
            name: .showAddressSelected,
            object: nil,
            userInfo: [NotificationConstants.showPlacemark: placemarkToBePosted]
        )

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(placemarkToBePosted.formattedAddress, sut.showAddress)
        XCTAssertEqual(placemarkToBePostedLatitude, sut.showLatitude)
        XCTAssertEqual(placemarkToBePostedLongitude, sut.showLongitude)
        XCTAssertEqual([placemarkToBePostedLatitude, placemarkToBePostedLongitude], sut.showTypesenseCoordinates)
        XCTAssertEqual(placemarkToBePosted.postalAddress!.city, sut.showCity)
        XCTAssertEqual(placemarkToBePosted.postalAddress!.state, sut.showState)
    }

    func test_OnIncrementMaxNumberOfBands_ValueIncrementsWhenMaxNumberOfBandsIsBelow101() {
        sut = AddEditShowViewModel()
        sut.showMaxNumberOfBands = 3
        sut.incrementMaxNumberOfBands()

        XCTAssertEqual(sut.showMaxNumberOfBands, 4)
    }

    func test_OnIncrementMaxNumberOfBands_MaxNumberOfBandsDoesNotRiseAbove101() {
        sut = AddEditShowViewModel()
        sut.showMaxNumberOfBands = 100
        sut.incrementMaxNumberOfBands()
        sut.incrementMaxNumberOfBands()
        sut.incrementMaxNumberOfBands()

        XCTAssertEqual(sut.showMaxNumberOfBands, 101)
    }

    func test_OnDecrementMaxNumberOfBands_ValueDecrementsWhenMaxNumberOfBandsIsAbove1() {
        sut = AddEditShowViewModel()
        sut.showMaxNumberOfBands = 10
        sut.decrementMaxNumberOfBands()

        XCTAssertEqual(sut.showMaxNumberOfBands, 9)
    }

    func test_OnDecrementMaxNumberOfBands_MaxNumberOfBandsDoesNotFallBelow1() {
        sut = AddEditShowViewModel()
        sut.showMaxNumberOfBands = 2
        sut.decrementMaxNumberOfBands()
        sut.decrementMaxNumberOfBands()
        sut.decrementMaxNumberOfBands()

        XCTAssertEqual(sut.showMaxNumberOfBands, 1)
    }

    func test_OnUpdateCreateShowButtonTappedWithNoImageAndNoShowToEdit_ShowIsCreatedWithNoImage() async throws {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        // Ensures that properties are filled but showToEdit is nil so that correct methods are called
        sut.showToEdit = nil

        guard let createdShowDocumentId = await sut.updateCreateShowButtonTapped() else {
            XCTFail("A document ID should've been returned by the method")
            return
        }
        self.createdShowDocumentId = createdShowDocumentId
        let createdShow = try await testingDatabaseService.getShow(with: createdShowDocumentId)

        XCTAssertEqual(createdShow.name, TestingConstants.exampleShowForIntegrationTesting.name)
        XCTAssertTrue(sut.formIsComplete, "The form should be complete since a show was passed in")
        XCTAssertEqual(sut.viewState, .workCompleted, ".workCompleted should be the viewState after a show is created")
    }

    func test_OnUpdateCreateShowButtonTappedWithImageAndNoShowToEdit_ShowIsCreatedWithImage() async throws {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        // Ensures that properties are filled but showToEdit is nil so that correct methods are called
        sut.showToEdit = nil

        guard let createdShowDocumentId = await sut.updateCreateShowButtonTapped(withImage: TestingConstants.uiImageForTesting) else {
            XCTFail("A document ID should've been returned by the method")
            return
        }
        let createdShow = try await testingDatabaseService.getShow(with: createdShowDocumentId)
        let showImageExists = try await testingDatabaseService.imageExists(at: createdShow.imageUrl)
        self.createdShowDocumentId = createdShowDocumentId
        self.createdShowImageDownloadUrl = createdShow.imageUrl

        XCTAssertTrue(sut.formIsComplete, "The form should be complete since a show was passed in")
        XCTAssertEqual(createdShow.name, TestingConstants.exampleShowForIntegrationTesting.name, "The incorrect shows are being compared")
        XCTAssertTrue(showImageExists, "An image should've been created for the show")
        XCTAssertEqual(sut.viewState, .workCompleted, ".workCompleted should be the viewState after a show is created")
    }

    func test_OnUpdateCreateShowButtonTappedWithShowToEdit_ShowIsUpdated() async throws {
        self.createdShowDocumentId = try testingDatabaseService.createShow(TestingConstants.exampleShowForIntegrationTesting)
        var showToEdit = TestingConstants.exampleShowForIntegrationTesting
        // Necessary so that the edited show has the same id as the one that's in Firestore already
        showToEdit.id = createdShowDocumentId!
        sut = AddEditShowViewModel(showToEdit: showToEdit)

        sut.showName = "UPDATED TEST SHOW"
        _ = await sut.updateCreateShowButtonTapped()
        let updatedShow = try await testingDatabaseService.getShow(with: createdShowDocumentId!)

        XCTAssertTrue(sut.formIsComplete, "The form should be complete since a show was passed in")
        XCTAssertEqual(updatedShow.name, "UPDATED TEST SHOW", "The show name was not updated")
        XCTAssertEqual(updatedShow.id, createdShowDocumentId!, "The incorrect shows are being compared")
        XCTAssertEqual(sut.viewState, .workCompleted, ".workCompleted should be the viewState after a show is created")
    }

    func test_OnUpdateCreateShowButtonTappedWithIncompleteFormAndNoShowToEdit_ErrorIsThrownAndViewStateIsSet() async {
        sut = AddEditShowViewModel()

        let showDocumentId = await sut.updateCreateShowButtonTapped()

        XCTAssertNil(showDocumentId, "There can't be a document ID because show creation shouldn't be successful")
        XCTAssertFalse(sut.formIsComplete, "The form is incomplete because all required fields are empty")
        XCTAssertEqual(sut.viewState, .error(message: LogicError.incompleteForm.localizedDescription))
        XCTAssertEqual(sut.errorAlertText, LogicError.incompleteForm.localizedDescription, "The user should see this error alert text")
        XCTAssertTrue(sut.errorAlertIsShowing, "The user should see an error alert")
        XCTAssertFalse(sut.createShowButtonIsDisabled, "The button should be re-enabled so the user can try again")
    }

    func test_OnUpdateCreateShowButtonTappedWithIncompleteFormAndWithShowToEdit_ErrorIsThrownAndViewStateIsSet() async {
        sut = AddEditShowViewModel(showToEdit: TestingConstants.exampleShowForIntegrationTesting)
        sut.showName = "  "

        let showDocumentId = await sut.updateCreateShowButtonTapped()

        XCTAssertNil(showDocumentId, "There can't be a document ID because show creation shouldn't be successful")
        XCTAssertFalse(sut.formIsComplete, "The form is incomplete because all required fields are empty")
        XCTAssertEqual(sut.viewState, .error(message: LogicError.incompleteForm.localizedDescription))
        XCTAssertEqual(sut.errorAlertText, LogicError.incompleteForm.localizedDescription, "The user should see this error alert text")
        XCTAssertTrue(sut.errorAlertIsShowing, "The user should see an error alert")
        XCTAssertFalse(sut.createShowButtonIsDisabled, "The button should be re-enabled so the user can try again")
    }

    func test_OnPerformingWorkViewState_ExpectedWorkIsPerformed() {
        sut = AddEditShowViewModel()

        sut.viewState = .performingWork

        XCTAssertTrue(sut.createShowButtonIsDisabled, "The button should be disabled while work is being performed")
    }

    func test_OnWorkCompletedViewState_ExpectedWorkIsPerformed() {
        sut = AddEditShowViewModel()

        sut.viewState = .workCompleted

        XCTAssertTrue(sut.showCreatedSuccessfully, "If this view state is set, it means that the show was successfully altered or created")
    }

    func test_OnErrorViewState_ExpectedWorkIsPerformed() {
        sut = AddEditShowViewModel()

        sut.viewState = .error(message: "AN ERROR HAPPENED")

        XCTAssertTrue(sut.errorAlertIsShowing, "An error alert should be presented")
        XCTAssertEqual(sut.errorAlertText, "AN ERROR HAPPENED", "The error message should be assigned to the text property")
        XCTAssertFalse(sut.createShowButtonIsDisabled, "The user should be able to retry after an error occurs")
    }
}
