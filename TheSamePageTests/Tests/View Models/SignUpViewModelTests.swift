//
//  SignUpViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/13/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class SignUpViewModelTests: XCTestCase {
    var sut: SignUpViewModel!
    var testingDatabaseService: TestingDatabaseService!
    /// Makes it easier to delete an example user that's created for testing in tearDown method. Any user
    /// that's created in these tests should assign its id property to this property so that it can be deleted
    /// during tearDown.
    var createdUserUid: String?
    var createdImageDownloadUrl: String?
    let tim = TestingConstants.exampleUserTimForIntegrationTesting

    override func setUpWithError() throws {
        sut = SignUpViewModel()
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDown() async throws {
        if let createdImageDownloadUrl {
            try await testingDatabaseService.deleteImage(at: createdImageDownloadUrl)
            self.createdImageDownloadUrl = nil
        }

        if let createdUserUid {
            try await testingDatabaseService.deleteAccountInFirebaseAuthAndFirestore(forUserWithUid: createdUserUid)
            self.createdUserUid = nil
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertTrue(sut.username.isEmpty)
        XCTAssertTrue(sut.emailAddress.isEmpty)
        XCTAssertNil(sut.profileImage)
        XCTAssertTrue(sut.password.isEmpty)
        XCTAssertTrue(sut.firstName.isEmpty)
        XCTAssertTrue(sut.lastName.isEmpty)
        XCTAssertNil(sut.phoneNumber)
        XCTAssertFalse(sut.imagePickerIsShowing)
        XCTAssertFalse(sut.profileCreationWasSuccessful)
        XCTAssertFalse(sut.signUpButtonIsDisabled)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut.viewState = .performingWork

        XCTAssertTrue(sut.signUpButtonIsDisabled, "The sign up button should be disabled while the system signs the user in")
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut.viewState = .workCompleted

        XCTAssertTrue(sut.profileCreationWasSuccessful, "If sign up was completed, then profile creation was successful.")
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR", "The user should see the above error message when there's an error")
        XCTAssertTrue(sut.errorAlertIsShowing, "The user should see an error alert")
        XCTAssertFalse(sut.signUpButtonIsDisabled, "The user should be able to try again after seeing an error")
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut.viewState = .dataNotFound

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_FormIsComplete_ReturnsTrueWithFirstNameAndLastNameFieldsFilled() {
        sut.firstName = "Julian"
        sut.lastName = "Worden"

        XCTAssertTrue(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithFirstNameAndNoLastName() {
        sut.firstName = "Julian"

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNoFirstNameAndWithLastName() {
        sut.lastName = "Worden"

        XCTAssertFalse(sut.formIsComplete)
    }

    func test_FormIsComplete_ReturnsFalseWithNoFirstNameAndNoLastName() {
        XCTAssertFalse(sut.formIsComplete)
    }

    func test_OnSignUpButtonTappedWithCompleteFormAndValidAccountInfoAndNoProfileImage_NewUserIsSignedOut() async throws {
        setTimCookAccountInfoInViewModelProperties()

        createdUserUid = await sut.signUpButtonTapped()

        XCTAssertTrue(AuthController.userIsLoggedOut(), "The user should get logged out ")

        // Necessary so that objects can get deleted in tearDown
        try await testingDatabaseService.logInToTimAccount()
    }

    func test_OnSignUpButtonTappedWithCompleteFormAndValidAccountInfoAndNoProfileImage_NewUserIsCreatedInFirestore() async throws {
        setTimCookAccountInfoInViewModelProperties()

        createdUserUid = await sut.signUpButtonTapped()
        try await testingDatabaseService.logInToTimAccount()
        let createdUser = try await testingDatabaseService.getUserFromFirestore(withUid: createdUserUid!)

        XCTAssertEqual(tim.firstName, createdUser.firstName)
        XCTAssertEqual(tim.lastName, createdUser.lastName)
        XCTAssertEqual(tim.emailAddress, createdUser.emailAddress)
        XCTAssertEqual(tim.username, createdUser.username)
    }

    func test_OnSignUpButtonTappedWithCompleteFormAndValidAccountInfoAndNoProfileImage_NewUserIsCreatedInFirebaseAuth() async throws {
        setTimCookAccountInfoInViewModelProperties()

        createdUserUid = await sut.signUpButtonTapped()
        try await testingDatabaseService.logInToTimAccount()
        let createdUser = testingDatabaseService.getLoggedInUserFromFirebaseAuth()

        XCTAssertNotNil(createdUser, "The user should've been created and become the Auth.auth().currentUser")
        XCTAssertEqual(tim.emailAddress, createdUser!.email)
    }

    func test_OnSignUpButtonTappedWithCompleteFormAndValidAccountInfoAndWithProfileImage_NewUserAndImageAreCreated() async throws {
        setTimCookAccountInfoInViewModelProperties()
        sut.profileImage = TestingConstants.uiImageForTesting

        createdUserUid = await sut.signUpButtonTapped()
        try await testingDatabaseService.logInToTimAccount()
        let createdUser = try await testingDatabaseService.getUserFromFirestore(withUid: createdUserUid!)
        createdImageDownloadUrl = createdUser.profileImageUrl
        let profileImageExistsInFirebaseStorage = try await testingDatabaseService.imageExists(at: createdImageDownloadUrl)

        XCTAssertNotNil(createdImageDownloadUrl, "The user should have a profile image")
        XCTAssertTrue(profileImageExistsInFirebaseStorage, "The user's profile image should be getting stored in Firebase Storage")
    }

    func test_OnSignUpButtonTappedWithIncompleteForm_ErrorViewStateIsSet() async {
        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.incompleteFormOnSignUp))
    }

    func test_OnSignUpButtonTappedWithInvalidEmail_CorrectErrorIsThrown() async {
        setTimCookAccountInfoInViewModelProperties()
        sut.emailAddress = "timcook"

        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.invalidOrMissingEmailOnSignUp), "Firebase should detect that this isn't a valid email address")
    }

    func test_OnSignUpButtonTappedWithNoEmail_CorrectErrorIsThrown() async {
        setTimCookAccountInfoInViewModelProperties()
        sut.emailAddress = ""

        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.invalidOrMissingEmailOnSignUp), "An account can't be created without an email address")
    }

    func test_OnSignUpButtonTappedWithEmailAlreadyInUse_CorrectErrorIsThrown() async {
        setTimCookAccountInfoInViewModelProperties()
        sut.emailAddress = "julianworden@gmail.com"

        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.emailAlreadyInUseOnSignUp), "There should be an existing account with julianworden@gmail.com being used as the email address")
    }

    func test_OnSignUpButtonTappedWithWeakPassword_CorrectErrorIsThrown() async {
        setTimCookAccountInfoInViewModelProperties()
        sut.password = "1234"

        await sut.signUpButtonTapped()

        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.weakPasswordOnSignUp), "Firebase should detect that the password isn't longer than 6 characters")
    }

    func setTimCookAccountInfoInViewModelProperties() {
        sut.firstName = tim.firstName
        sut.lastName = tim.lastName
        sut.emailAddress = tim.emailAddress
        sut.password = "dynomite"
        sut.username = tim.username
    }
}
