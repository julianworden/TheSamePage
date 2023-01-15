//
//  LoginViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/13/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class LoginViewModelTests: XCTestCase {
    var sut: LoginViewModel!
    var testingDatabaseService: TestingDatabaseService!

    override func setUpWithError() throws {
        sut = LoginViewModel()
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertTrue(sut.emailAddress.isEmpty)
        XCTAssertTrue(sut.password.isEmpty)
        XCTAssertFalse(sut.loginErrorShowing)
        XCTAssertTrue(sut.loginErrorMessage.isEmpty)
        XCTAssertFalse(sut.loginButtonIsDisabled)
        XCTAssertTrue(sut.userIsOnboarding)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut.viewState = .performingWork

        XCTAssertTrue(sut.loginButtonIsDisabled, "The Log In button should be disabled while the system attempts to log the user in")
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut.viewState = .workCompleted

        XCTAssertFalse(sut.userIsOnboarding, "When the user is logged in successfully, they should no longer be onboarding")
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.loginErrorMessage, "TEST ERROR", "The user should see the error message set above")
        XCTAssertTrue(sut.loginErrorShowing, "The user should see an error message")
        XCTAssertFalse(sut.loginButtonIsDisabled, "The user should be able to attempt to log in again after getting an error")
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut.viewState = .dataLoaded

        XCTAssertEqual(sut.loginErrorMessage, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.loginErrorShowing)
    }

    func test_OnLogInUserWithValidCredentials_UserIsLoggedIn() async throws {
        await sut.logInUserWith(emailAddress: "julianworden@gmail.com", password: "dynomite")
        let julian = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserJulian.id)
        let currentUser = testingDatabaseService.getLoggedInUserFromFirebaseAuth()

        XCTAssertNotNil(currentUser, "Julian should be the currentUser")
        XCTAssertEqual(currentUser!.displayName, julian.username, "Julian's username should match the currentUser's display name")
        XCTAssertEqual(currentUser!.email, julian.emailAddress, "Julian's email address should match the currentUser's email address")
    }

    func test_OnLogInUserWithInvalidEmail_CorrectErrorIsThrown() async {
        await sut.logInUserWith(emailAddress: "julianworden", password: "dynomite")
        let currentUser = testingDatabaseService.getLoggedInUserFromFirebaseAuth()

        XCTAssertNil(currentUser, "No one should've been signed in")
        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.invalidEmailAddressOnSignIn))
    }

    func test_OnLogInUserWithWrongPassword_CorrectErrorIsThrown() async {
        await sut.logInUserWith(emailAddress: "julianworden@gmail.com", password: "asdfasdf")
        let currentUser = testingDatabaseService.getLoggedInUserFromFirebaseAuth()

        XCTAssertNil(currentUser, "No one should've been signed in")
        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.wrongPasswordOnSignIn))
    }

    func test_OnLogInUserWithCredentialsThatDontBelongToAUser_CorrectErrorIsThrown() async {
        await sut.logInUserWith(emailAddress: "abcdefg@gmail.com", password: "asdfasdf")
        let currentUser = testingDatabaseService.getLoggedInUserFromFirebaseAuth()

        XCTAssertNil(currentUser, "No one should've been signed in")
        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.userNotFoundOnSignIn))
    }
}
