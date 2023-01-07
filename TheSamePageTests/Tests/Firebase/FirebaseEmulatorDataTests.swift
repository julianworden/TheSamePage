//
//  FirebaseEmulatorDataTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/4/23.
//

@testable import TheSamePage

import XCTest

final class FirebaseEmulatorDataTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    // MARK: - Firestore Example Shows

    func test_OnInit_ExampleShowInFirestoreEmulatorHasExpectedValues() async throws {
        let exampleShow = try await testingDatabaseService.getShow(TestingConstants.exampleShowDumpweedExtravaganza)

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
        let exampleShow = try await testingDatabaseService.getShow(TestingConstants.exampleShowDumpweedExtravaganza)

        XCTAssertEqual(exampleShow, TestingConstants.exampleShowDumpweedExtravaganza, "The example show should already exist in the emulator")
    }

    // MARK: - Firestore Example Users

    func test_OnInit_ExampleUserJulianInFirestoreEmulatorHasExpectedValues() async throws {
        let julian = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserJulian)

        XCTAssertEqual(julian.id, "qvJ5tmKpih3mFkUCet5CPREg3qjZ")
        XCTAssertEqual(julian.firstName, "Julian")
        XCTAssertEqual(julian.lastName, "Worden")
        XCTAssertEqual(julian.profileImageUrl, "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/JMTech%20Profile%20Pic.jpeg?alt=media&token=511ccc65-8205-4d13-9802-74af76e42098")
        XCTAssertEqual(julian.username, "julianworden")
        XCTAssertEqual(julian.emailAddress, "julianworden@gmail.com")
        XCTAssertNil(julian.fcmToken)
        XCTAssertNil(julian.phoneNumber)
    }

    func test_OnInit_ExampleUserLouInFirestoreEmulatorHasExpectedValues() async throws {
        let lou = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserLou)

        XCTAssertEqual(lou.id, "CsXJnPfi5ZT9jr2uQUsO4jz040Et")
        XCTAssertEqual(lou.firstName, "Lou")
        XCTAssertEqual(lou.lastName, "Sabba")
        XCTAssertNil(lou.profileImageUrl)
        XCTAssertEqual(lou.username, "lousabba")
        XCTAssertEqual(lou.emailAddress, "lousabba@gmail.com")
        XCTAssertNil(lou.fcmToken)
        XCTAssertNil(lou.phoneNumber)
    }

    func test_OnInit_ExampleUserTasInFirestoreEmulatorHasExpectedValues() async throws {
        let tas = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserTas)

        XCTAssertEqual(tas.id, "FNl8cxPCoELjL8WsxRfliNP0Lmhq")
        XCTAssertEqual(tas.firstName, "Tas")
        XCTAssertEqual(tas.lastName, "Cioppa")
        XCTAssertNil(tas.profileImageUrl)
        XCTAssertEqual(tas.username, "tascioppa")
        XCTAssertEqual(tas.emailAddress, "tascioppa@gmail.com")
        XCTAssertNil(tas.fcmToken)
        XCTAssertNil(tas.phoneNumber)
    }

    func test_OnInit_ExampleUserEricInFirestoreEmulatorHasExpectedValues() async throws {
        let eric = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserEric)

        XCTAssertEqual(eric.id, "K4rrOL8effR2ULYb3dDN5eMlXvWn")
        XCTAssertEqual(eric.firstName, "Eric")
        XCTAssertEqual(eric.lastName, "Palermo")
        XCTAssertNil(eric.profileImageUrl)
        XCTAssertEqual(eric.username, "ericpalermo")
        XCTAssertEqual(eric.emailAddress, "ericpalermo@gmail.com")
        XCTAssertNil(eric.fcmToken)
        XCTAssertNil(eric.phoneNumber)
    }

    func test_OnInit_ExampleUserMikeInFirestoreEmulatorHasExpectedValues() async throws {
        let mike = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserMike)

        XCTAssertEqual(mike.id, "0b5ozNAbBQ1ObJXNRCHDB4OjGzwi")
        XCTAssertEqual(mike.firstName, "Mike")
        XCTAssertEqual(mike.lastName, "Florentine")
        XCTAssertNil(mike.profileImageUrl)
        XCTAssertEqual(mike.username, "mikeflorentine")
        XCTAssertEqual(mike.emailAddress, "mikeflorentine@gmail.com")
        XCTAssertNil(mike.fcmToken)
        XCTAssertNil(mike.phoneNumber)
    }

    func test_OnInit_ExampleUsersInFirestoreEmulatorMatchTestingConstants() async throws {
        let julianInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserJulian)
        let ericInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserEric)
        let louInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserLou)
        let tasInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserTas)
        let mikeInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserMike)

        XCTAssertEqual(julianInEmulator, TestingConstants.exampleUserJulian, "The TestingConstants and Firestore Emulator do not match")
        XCTAssertEqual(ericInEmulator, TestingConstants.exampleUserEric, "The TestingConstants and Firestore Emulator do not match")
        XCTAssertEqual(louInEmulator, TestingConstants.exampleUserLou, "The TestingConstants and Firestore Emulator do not match")
        XCTAssertEqual(tasInEmulator, TestingConstants.exampleUserTas, "The TestingConstants and Firestore Emulator do not match")
        XCTAssertEqual(mikeInEmulator, TestingConstants.exampleUserMike, "The TestingConstants and Firestore Emulator do not match")
    }

    func test_OnInit_ExampleUserEricInFirestoreEmulatorMatchesTestingConstants() async throws {

    }

    // MARK: - Firestore Example Bands

    func test_OnInit_ExampleBandPatheticFallacyInFirestoreEmulatorHasExpectedValues() async throws {
        let patheticFallacy = try await testingDatabaseService.getBand(TestingConstants.exampleBandPatheticFallacy)

        XCTAssertEqual(patheticFallacy.adminUid, TestingConstants.exampleUserJulian.id)
        XCTAssertEqual(patheticFallacy.bio, "We're a metal core band from central New Jersey!")
        XCTAssertEqual(patheticFallacy.city, "Neptune")
        XCTAssertEqual(patheticFallacy.genre, Genre.metalcore.rawValue)
        XCTAssertEqual(patheticFallacy.id, "C7ZbA7gaeQ7Lk1Kid9QC")
        XCTAssertTrue(patheticFallacy.memberFcmTokens.isEmpty)
        XCTAssertEqual(patheticFallacy.memberUids, [TestingConstants.exampleUserJulian.id, TestingConstants.exampleUserLou.id])
        XCTAssertEqual(patheticFallacy.name, "Pathetic Fallacy")
        XCTAssertEqual(patheticFallacy.state, BandState.NJ.rawValue)
    }

    func test_OnInit_ExampleBandDumpweedInFirestoreEmulatorHasExpectedValues() async throws {
        let dumpweed = try await testingDatabaseService.getBand(TestingConstants.exampleBandDumpweed)

        XCTAssertEqual(dumpweed.adminUid, TestingConstants.exampleUserEric.id)
        XCTAssertEqual(dumpweed.bio, "We are the biggest rockers in the whole wide world!")
        XCTAssertEqual(dumpweed.city, "New Brunswick")
        XCTAssertEqual(dumpweed.genre, Genre.metal.rawValue)
        XCTAssertEqual(dumpweed.id, "utwW2iCnJ7MiGAdRfFYz")
        XCTAssertTrue(dumpweed.memberFcmTokens.isEmpty)
        XCTAssertEqual(dumpweed.memberUids, [TestingConstants.exampleUserEric.id])
        XCTAssertEqual(dumpweed.name, "Dumpweed")
        XCTAssertEqual(dumpweed.state, BandState.NJ.rawValue)
    }

    func test_OnInit_ExampleBandsInFirestoreEmulatorMatchExampleBandsInTestingConstants() async throws {
        let patheticFallacyInEmulator = try await testingDatabaseService.getBand(TestingConstants.exampleBandPatheticFallacy)
        let dumpweedInEmulator = try await testingDatabaseService.getBand(TestingConstants.exampleBandDumpweed)

        XCTAssertEqual(patheticFallacyInEmulator, TestingConstants.exampleBandPatheticFallacy, "The example bands in emulator and in the project should match")
        XCTAssertEqual(dumpweedInEmulator, TestingConstants.exampleBandDumpweed, "The example bands in emulator and in the project should match")
    }

    // MARK: - Firestore Example BandInvites

    func test_OnInit_ExampleBandInviteInFirestoreEmulatorHasExpectedValues() async throws {
        let bandInvite = try await testingDatabaseService.getBandInvite(get: TestingConstants.exampleBandInvite, for: TestingConstants.exampleUserTas)

        XCTAssertEqual(bandInvite.id, "I8jPC6U14IolWMSc8Ivp")
        XCTAssertEqual(bandInvite.dateSent, 1673073450)
        XCTAssertEqual(bandInvite.notificationType, NotificationType.bandInvite.rawValue)
        XCTAssertEqual(bandInvite.recipientUid, "FNl8cxPCoELjL8WsxRfliNP0Lmhq")
        XCTAssertEqual(bandInvite.recipientRole, "Drums")
        XCTAssertEqual(bandInvite.bandId, "C7ZbA7gaeQ7Lk1Kid9QC")
        XCTAssertEqual(bandInvite.senderUsername, "julianworden")
        XCTAssertEqual(bandInvite.senderBand, "Pathetic Fallacy")
        XCTAssertEqual(bandInvite.message, "julianworden is inviting you to join Pathetic Fallacy")
    }

    func test_OnInit_ExampleBandInvitesInFirestoreEmulatorMatchTestingConstants() async throws {
        let bandInviteInEmulator = try await testingDatabaseService.getBandInvite(get: TestingConstants.exampleBandInvite, for: TestingConstants.exampleUserTas)

        XCTAssertEqual(bandInviteInEmulator, TestingConstants.exampleBandInvite)
    }

    // MARK: - Firestore Example BandMembers

    func test_OnInit_ExampleBandMemberJulianInFirestoreEmulatorHasExpectedValues() async throws {
        let julian = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberJulian,
            in: TestingConstants.exampleBandPatheticFallacy
        )

        XCTAssertEqual(julian.id, "JcNG3facFtTva2scVKDZ")
        XCTAssertEqual(julian.dateJoined, 1673073450)
        XCTAssertEqual(julian.uid, "qvJ5tmKpih3mFkUCet5CPREg3qjZ")
        XCTAssertEqual(julian.role, "Vocals")
        XCTAssertEqual(julian.username, "julianworden")
        XCTAssertEqual(julian.fullName, "Julian Worden")
    }

    func test_OnInit_ExampleBandMemberLouInFirestoreEmulatorHasExpectedValues() async throws {
        let lou = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberLou,
            in: TestingConstants.exampleBandPatheticFallacy
        )

        XCTAssertEqual(lou.id, "KgjxDt61nxsNMR4PSvdO")
        XCTAssertEqual(lou.dateJoined, 1673073450)
        XCTAssertEqual(lou.uid, "CsXJnPfi5ZT9jr2uQUsO4jz040Et")
        XCTAssertEqual(lou.role, "Guitar")
        XCTAssertEqual(lou.username, "lousabba")
        XCTAssertEqual(lou.fullName, "Lou Sabba")
    }

    func test_OnInit_ExampleBandMemberEricInFirestoreEmulatorHasExpectedValues() async throws {
        let eric = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberEric,
            in: TestingConstants.exampleBandDumpweed
        )

        XCTAssertEqual(eric.id, "d6Nvz616sgY7zPll0Wh8")
        XCTAssertEqual(eric.dateJoined, 1673073450)
        XCTAssertEqual(eric.uid, "K4rrOL8effR2ULYb3dDN5eMlXvWn")
        XCTAssertEqual(eric.role, "Vocals")
        XCTAssertEqual(eric.username, "ericpalermo")
        XCTAssertEqual(eric.fullName, "Eric Palermo")
    }

    // MARK: - Firestore Example Chats

    func test_OnInit_ExampleChatDumpweedExtravaganzaInFirestoreEmulatorHasExpectedValues() async throws {
        let chat = try await testingDatabaseService.getChat(TestingConstants.exampleChatDumpweedExtravaganza)

        XCTAssertEqual(chat.id, "cpS2HseZT6XIG1qMRAKL")
        XCTAssertEqual(chat.showId, TestingConstants.exampleShowDumpweedExtravaganza.id)
        XCTAssertEqual(chat.name, TestingConstants.exampleShowDumpweedExtravaganza.name)
        XCTAssertEqual(
            chat.participantUids,
            [
                TestingConstants.exampleUserJulian.id,
                TestingConstants.exampleUserLou.id,
                TestingConstants.exampleUserEric.id
            ]
        )
        XCTAssertTrue(chat.participantFcmTokens.isEmpty)
        XCTAssertNil(chat.userId)
    }

    func test_OnInit_ExampleChatsInFirestoreEmulatorMatchTestingConstants() async throws {
        let dumpweedExtravaganzaChatInEmulator = try await testingDatabaseService.getChat(TestingConstants.exampleChatDumpweedExtravaganza)
        let dumpweedExtravaganzaChatInTestingConstants = TestingConstants.exampleChatDumpweedExtravaganza

        XCTAssertEqual(dumpweedExtravaganzaChatInEmulator, dumpweedExtravaganzaChatInTestingConstants)
    }

    // MARK: - Firebase Auth

    func test_OnInit_FirebaseAuthEmulatorContainsTestAccount() async throws {
        guard let currentUser = try await testingDatabaseService.logInToJulianAccount() else {
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

        try testingDatabaseService.logOut()

        XCTAssertNil(testingDatabaseService.getLoggedInUserFromFirebaseAuth(), "The user should be logged out")
    }

    // MARK: - Firebase Storage

    func test_OnInit_FirebaseStorageEmulatorContainsExampleUserProfileImage() async throws {
        let profileImageUrl = try await testingDatabaseService.getDownloadLinkForUserProfileImage(TestingConstants.exampleUserJulian)

        XCTAssertEqual(profileImageUrl, TestingConstants.exampleUserJulian.profileImageUrl)
    }
}
