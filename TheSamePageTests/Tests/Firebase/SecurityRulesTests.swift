//
//  SecurityRulesTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/4/23.
//

@testable import TheSamePage

import FirebaseFirestore
import FirebaseStorage
import XCTest

final class SecurityRulesTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!

    override func setUpWithError() throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        testingDatabaseService = nil
    }

    func test_WhenLoggedOut_ReadingFirestoreDataIsNotPossible() async throws {
        do {
            XCTAssertNoThrow(try testingDatabaseService.logOutOfTestAccount(), "If this call throws, it'll skew the result of the test")
            _ = try await testingDatabaseService.getShow(TestingConstants.exampleShowInEmulator)

            XCTFail("The read should not have been successful because the user was logged out")
        } catch FirestoreErrorCode.permissionDenied {
            XCTAssert(true)
        } catch {
            XCTFail("The test should've failed due to denied permission, not for any other reason")
        }
    }

    func test_WhenLoggedOut_ReadingFirebaseStorageDataIsNotPossible() async throws {
        do {
            XCTAssertNoThrow(try testingDatabaseService.logOutOfTestAccount(), "If this call throws, it'll skew the result of the test")
            _ = try await testingDatabaseService.getDownloadLinkForUserProfileImage(TestingConstants.exampleUserInEmulator)

            XCTFail("The read should've failed because the user was signed out")
        } catch {
            // Not ideal, but it seems that catching the StorageError.code does not work like it does with FirestoreErrorCode and AuthErrorCode.
            // This works because this is the error that's printed when the expected error is thrown
            XCTAssertEqual("unauthorized(\"the-same-page-9c69e.appspot.com\", \"JMTech Profile Pic.jpeg\")", "\(error)")
        }
    }
}
