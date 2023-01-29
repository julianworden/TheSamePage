//
//  CreateUsernameViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/29/23.
//

@testable import TheSamePage

import FirebaseAuth
import XCTest

@MainActor
final class CreateUsernameViewModelTests: XCTestCase {
    var sut: CreateUsernameViewModel!
    var testingDatabaseService: TestingDatabaseService!

    override func setUpWithError() throws {
        sut = CreateUsernameViewModel()
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertTrue(sut.username.isEmpty)
        XCTAssertFalse(sut.createUsernameButtonIsDisabled)
        XCTAssertFalse(sut.usernameCreationWasSuccessfulAlertIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnPerformingWorkViewState_ExpectedWorkIsPerformed() {
        sut.viewState = .performingWork

        XCTAssertTrue(sut.createUsernameButtonIsDisabled, "The button should be disabled while work is being performed.")
    }

    func test_OnWorkCompletedViewState_ExpectedWorkIsPerformed() {
        sut.viewState = .workCompleted

        XCTAssertTrue(sut.usernameCreationWasSuccessfulAlertIsShowing, "If this view state is set, it means that the username was successfully created.")
    }

    func test_OnErrorViewState_ExpectedWorkIsPerformed() {
        sut.viewState = .error(message: "AN ERROR HAPPENED")

        XCTAssertTrue(sut.errorAlertIsShowing, "An error alert should be presented.")
        XCTAssertEqual(sut.errorAlertText, "AN ERROR HAPPENED", "The error message should be assigned to the text property.")
        XCTAssertFalse(sut.createUsernameButtonIsDisabled, "The user should be able to retry after an error occurs.")
    }

    func test_OnInvalidViewState_PropertiesAreChanged() {
        sut.viewState = .dataNotFound

        XCTAssertTrue(sut.errorAlertIsShowing)
        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
    }

    func test_UsernameIsValid_ReturnsTrueForUsernameNotInUse() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut.username = "exampleusername"

        let usernameIsValid = try await sut.usernameIsValid()

        XCTAssertTrue(usernameIsValid, "No user should exist with a username of exampleusername.")
    }

    func test_UsernameIsValid_ReturnsFalseAndSetsViewStateForUsernameAlreadyInUse() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut.username = "ericpalermo"

        let usernameIsValid = try await sut.usernameIsValid()

        XCTAssertFalse(usernameIsValid, "This username should be taken by Eric.")
        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.usernameIsAlreadyTaken)
        XCTAssertTrue(sut.errorAlertIsShowing)
        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.usernameIsAlreadyTaken))
    }

    func test_UsernameIsValid_ReturnsFalseAndSetsViewStateForUsernameThatIsTooShort() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut.username = "ab"

        let usernameIsValid = try await sut.usernameIsValid()

        XCTAssertFalse(usernameIsValid, "The username should be required to be 3 characters or more.")
        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.usernameIsTooShort)
        XCTAssertTrue(sut.errorAlertIsShowing)
        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.usernameIsTooShort))
    }

    func test_OnCreateUsernameWithValidUsername_UsernameIsCreated() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut.username = "jdawg"

        await sut.createUsername()
        let updatedJulianObjectInFirestore = try await testingDatabaseService.getUserFromFirestore(
            withUid: TestingConstants.exampleUserJulian.id
        )
        guard let currentUserInFirebaseAuth = AuthController.getLoggedInUser() else {
            XCTFail("Julian should be signed in, so there should be a currentUser.")
            return
        }

        XCTAssertEqual(sut.viewState, .workCompleted)
        XCTAssertEqual(currentUserInFirebaseAuth.displayName, "jdawg")
        XCTAssertEqual(updatedJulianObjectInFirestore.username, "jdawg")

        try await restoreJulianUsername()
    }

    func test_OnCreateUsernameWithInvalidUsername_UsernameIsNotCreated() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut.username = "jd"

        await sut.createUsername()
        let julianInFirestore = try await testingDatabaseService.getUserFromFirestore(
            withUid: TestingConstants.exampleUserJulian.id
        )
        guard let currentUserInFirebaseAuth = AuthController.getLoggedInUser() else {
            XCTFail("Julian should be signed in, so there should be a currentUser.")
            return
        }

        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.usernameIsTooShort))
        XCTAssertEqual(currentUserInFirebaseAuth.displayName, "julianworden")
        XCTAssertEqual(julianInFirestore.username, "julianworden")
    }

    func restoreJulianUsername() async throws {
        try await testingDatabaseService.editUserInfo(
            uid: TestingConstants.exampleUserJulian.id,
            field: FbConstants.username, newValue: TestingConstants.exampleUserJulian.username
        )
        let changeRequest = AuthController.getLoggedInUser()?.createProfileChangeRequest()
        changeRequest?.displayName = TestingConstants.exampleUserJulian.username
        try await changeRequest?.commitChanges()
    }
}
