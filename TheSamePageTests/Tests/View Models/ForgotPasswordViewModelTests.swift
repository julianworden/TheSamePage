//
//  ForgotPasswordViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/27/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class ForgotPasswordViewModelTests: XCTestCase {
    var sut: ForgotPasswordViewModel!
    var testingDatabaseService: TestingDatabaseService!

    override func setUpWithError() throws {
        sut = ForgotPasswordViewModel()
        testingDatabaseService = TestingDatabaseService()
        try testingDatabaseService.logOut()
    }

    override func tearDownWithError() throws {
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertTrue(sut.emailAddress.isEmpty)
        XCTAssertFalse(sut.buttonsAreDisabled)
        XCTAssertFalse(sut.successfullySentPasswordResetEmailAlertIsShowing)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.successfullySentPasswordResetEmailAlertText, "A password reset email was successfully sent to your email address. You can use the instructions in that email to reset your password.")
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() {
        sut.viewState = .performingWork

        XCTAssertTrue(sut.buttonsAreDisabled, "The Send Email button should be disabled while the system attempts to send the password reset email.")
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() {
        sut.viewState = .workCompleted

        XCTAssertTrue(sut.successfullySentPasswordResetEmailAlertIsShowing, "The view needs a way to know when the email was successfully sent.")
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR", "The user should see the error message set above.")
        XCTAssertTrue(sut.errorAlertIsShowing, "The user should see an error message.")
        XCTAssertFalse(sut.buttonsAreDisabled, "The user should be able to attempt to send the email again after getting an error.")
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut.viewState = .dataLoaded

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnSendPasswordEmail_CorrectErrorIsThrownWithUnknownUser() async {
        sut.emailAddress = "timtom@gmail.com"

        await sut.sendPasswordResetEmail()

        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.emailAddressDoesNotBelongToAccountOnForgotPassword))
    }

    func test_OnSendPasswordEmail_CorrectErrorIsThrownWithMissingEmailAddress() async {
        sut.emailAddress = ""

        await sut.sendPasswordResetEmail()

        XCTAssertEqual(sut.viewState, .error(message: ErrorMessageConstants.invalidEmailAddress))
    }

    func test_OnSendPasswordEmail_NoErrorIsThrownWithValidEmailAddressForExistingUser() async {
        sut.emailAddress = "julianworden@gmail.com"

        await sut.sendPasswordResetEmail()

        XCTAssertEqual(sut.viewState, .workCompleted, "This view state would've gotten set if the reset email was sent successfully")
    }

    // There is no test for confirming that the correct error is thrown for an .invalidEmail AuthErrorCode because that error
    // code does not get thrown in this situation on Firebase Emulator. It does get thrown when the app is connected to the actual Firebase service.
}
