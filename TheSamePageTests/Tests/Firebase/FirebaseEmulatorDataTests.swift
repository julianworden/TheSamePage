//
//  FirebaseEmulatorDataTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/4/23.
//

@testable import TheSamePage

import FirebaseAuth
import XCTest

final class FirebaseEmulatorDataTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToTestAccount()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOutOfTestAccount()
        testingDatabaseService = nil
    }

    // MARK: - Firestore

    func test_OnInit_ExampleShowInFirestoreEmulatorHasExpectedValues() async throws {
        let exampleShow = try await testingDatabaseService.getShow(TestingConstants.exampleShowInEmulator)

        XCTAssertEqual(exampleShow.address, "570 Jernee Mill Rd, Sayreville, NJ 08872")
        XCTAssertEqual(exampleShow.city, "Sayreville")
        XCTAssertEqual(exampleShow.date, 1668782049.620614)
        XCTAssertEqual(exampleShow.description, "A dank banger! Hop on the bill I freakin’ swear you won’t regret it! Like, it's gonna be the show of the absolute century, bro!")
        XCTAssertEqual(exampleShow.genre, "Rock")
        XCTAssertEqual(exampleShow.host, "DAA Entertainment")
        XCTAssertEqual(exampleShow.hostUid, "qvJ5tmKpih3mFkUCet5CPREg3qjZ")
        XCTAssertEqual(exampleShow.id, "Kk1NYjptTJITr0pjfVbe")
        XCTAssertEqual(exampleShow.imageUrl, "http://localhost:9199/v0/b/the-same-page-9c69e.appspot.com/o/images%2F24088E5A-F780-49FF-A2B2-ED841D40AF1C.jpg?alt=media&token=2199fdad-0868-4f75-b005-794933e5b9c3")
        XCTAssertEqual(exampleShow.latitude, 40.4404902)
        XCTAssertEqual(exampleShow.longitude, -74.355283)
        XCTAssertEqual(exampleShow.maxNumberOfBands, 2)
        XCTAssertEqual(exampleShow.minimumRequiredTicketsSold, 20)
        XCTAssertEqual(exampleShow.name, "Dumpweed Extravaganza")
        XCTAssertEqual(exampleShow.state, "NJ")
        XCTAssertEqual(exampleShow.ticketPrice, 100)
        XCTAssertEqual(exampleShow.typesenseCoordinates, [exampleShow.latitude, exampleShow.longitude])
        XCTAssertEqual(exampleShow.venue, "Starland Ballroom")
        XCTAssertTrue(exampleShow.addressIsPrivate)
        XCTAssertTrue(exampleShow.bandIds.isEmpty)
        XCTAssertTrue(exampleShow.hasBar)
        XCTAssertTrue(exampleShow.hasFood)
        XCTAssertTrue(exampleShow.is21Plus)
        XCTAssertFalse(exampleShow.isFree)
        XCTAssertTrue(exampleShow.participantUids.isEmpty)
        XCTAssertTrue(exampleShow.ticketSalesAreRequired)
        XCTAssertNil(exampleShow.loadInTime)
        XCTAssertNil(exampleShow.doorsTime)
        XCTAssertNil(exampleShow.musicStartTime)
        XCTAssertNil(exampleShow.endTime)
    }
    
    func test_OnInit_ExampleShowInFirestoreEmulatorMatchesExampleShowInTestingConstants() async throws {
        let exampleShow = try await testingDatabaseService.getShow(TestingConstants.exampleShowInEmulator)

        XCTAssertEqual(exampleShow, TestingConstants.exampleShowInEmulator, "The example show should already exist in the emulator")
    }

    func test_OnInit_ExampleUserInFirestoreEmulatorHasExpectedValues() async throws {
        let exampleUser = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserInEmulator)

        XCTAssertEqual(exampleUser.id, "qvJ5tmKpih3mFkUCet5CPREg3qjZ")
        XCTAssertEqual(exampleUser.firstName, "Julian")
        XCTAssertEqual(exampleUser.lastName, "Worden")
        XCTAssertEqual(exampleUser.profileImageUrl, "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/JMTech%20Profile%20Pic.jpeg?alt=media&token=511ccc65-8205-4d13-9802-74af76e42098")
        XCTAssertEqual(exampleUser.username, "julianworden")
        XCTAssertEqual(exampleUser.emailAddress, "julianworden@gmail.com")
        XCTAssertNil(exampleUser.fcmToken)
        XCTAssertNil(exampleUser.phoneNumber)
    }

    func test_OnInit_ExampleUserInFirestoreEmulatorMatchesExampleUserInTestingConstants() async throws {
        let exampleUser = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserInEmulator)

        XCTAssertEqual(exampleUser, TestingConstants.exampleUserInEmulator, "The example user should already exist in the emulator")
    }

    func test_OnInit_ExampleBandInFirestoreEmulatorHasExpectedValues() async throws {
        let exampleBand = try await testingDatabaseService.getBand(TestingConstants.exampleBandInEmulator)

        XCTAssertEqual(exampleBand.adminUid, "qvJ5tmKpih3mFkUCet5CPREg3qjZ")
        XCTAssertEqual(exampleBand.bio, "We're a metal core band from central New Jersey!")
        XCTAssertEqual(exampleBand.city, "Neptune")
        XCTAssertEqual(exampleBand.genre, "Metalcore")
        XCTAssertEqual(exampleBand.id, "C7ZbA7gaeQ7Lk1Kid9QC")
        XCTAssertTrue(exampleBand.memberFcmTokens.isEmpty)
        XCTAssertEqual(exampleBand.memberUids, [TestingConstants.exampleUserInEmulator.id])
        XCTAssertEqual(exampleBand.name, "Pathetic Fallacy")
        XCTAssertEqual(exampleBand.state, "NJ")
    }

    func test_OnInit_ExampleBandInFirestoreEmulatorMatchesExampleBandInTestingConstants() async throws {
        let exampleBand = try await testingDatabaseService.getBand(TestingConstants.exampleBandInEmulator)

        XCTAssertEqual(exampleBand, TestingConstants.exampleBandInEmulator, "The example bands in emulator and in the project should match")
    }

    // MARK: - Firebase Auth

    func test_OnInit_FirebaseAuthEmulatorContainsTestAccount() async throws {
        guard let currentUser = try await testingDatabaseService.logInToTestAccount() else {
            XCTFail("The user should be signed in before this test is run")
            return
        }

        XCTAssertEqual(currentUser.email, "julianworden@gmail.com", "The email address of the test user should be julianworden@gmail.com")
        XCTAssertEqual(currentUser.uid, "qvJ5tmKpih3mFkUCet5CPREg3qjZ", "qvJ5tmKpih3mFkUCet5CPREg3qjZ should be the UID of the test user")
    }

    func test_OnLogIn_CurrentUserExists() {
        XCTAssertTrue(testingDatabaseService.userIsLoggedIn(), "The user should've been signed in during setUp before this test was run")
    }

    func test_OnLogOut_FirebaseAuthEmulatorLogsOutUser() throws {
        XCTAssertNotNil(testingDatabaseService.getLoggedInUserFromFirebaseAuth(), "The user should've been signed in during setUp before this test was run")

        try testingDatabaseService.logOutOfTestAccount()

        XCTAssertNil(testingDatabaseService.getLoggedInUserFromFirebaseAuth(), "The user should be logged out")
    }

    // MARK: - Firebase Storage

    func test_OnInit_FirebaseStorageEmulatorContainsExampleUserProfileImage() async throws {
        let profileImageUrl = try await testingDatabaseService.getDownloadLinkForUserProfileImage(TestingConstants.exampleUserInEmulator)

        XCTAssertEqual(profileImageUrl, TestingConstants.exampleUserInEmulator.profileImageUrl)
    }
}
