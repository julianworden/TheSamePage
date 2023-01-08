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
        let exampleShowInEmulator = try await testingDatabaseService.getShow(TestingConstants.exampleShowDumpweedExtravaganza)
        let exampleShowInTestingConstants = TestingConstants.exampleShowDumpweedExtravaganza

        XCTAssertEqual(exampleShowInEmulator.address, exampleShowInTestingConstants.address)
        XCTAssertEqual(exampleShowInEmulator.city, exampleShowInTestingConstants.city)
        XCTAssertEqual(exampleShowInEmulator.date, exampleShowInTestingConstants.date)
        XCTAssertEqual(exampleShowInEmulator.description, exampleShowInTestingConstants.description)
        XCTAssertEqual(exampleShowInEmulator.genre, exampleShowInTestingConstants.genre)
        XCTAssertEqual(exampleShowInEmulator.host, exampleShowInTestingConstants.host)
        XCTAssertEqual(exampleShowInEmulator.hostUid, exampleShowInTestingConstants.hostUid)
        XCTAssertEqual(exampleShowInEmulator.id, exampleShowInTestingConstants.id)
        XCTAssertEqual(exampleShowInEmulator.imageUrl, exampleShowInTestingConstants.imageUrl)
        XCTAssertEqual(exampleShowInEmulator.latitude, exampleShowInTestingConstants.latitude)
        XCTAssertEqual(exampleShowInEmulator.longitude, exampleShowInTestingConstants.longitude)
        XCTAssertEqual(exampleShowInEmulator.maxNumberOfBands, exampleShowInTestingConstants.maxNumberOfBands)
        XCTAssertEqual(exampleShowInEmulator.minimumRequiredTicketsSold, exampleShowInTestingConstants.minimumRequiredTicketsSold)
        XCTAssertEqual(exampleShowInEmulator.name, exampleShowInTestingConstants.name)
        XCTAssertEqual(exampleShowInEmulator.state, exampleShowInTestingConstants.state)
        XCTAssertEqual(exampleShowInEmulator.ticketPrice, exampleShowInTestingConstants.ticketPrice)
        XCTAssertEqual(exampleShowInEmulator.typesenseCoordinates, exampleShowInTestingConstants.typesenseCoordinates)
        XCTAssertEqual(exampleShowInEmulator.venue, exampleShowInTestingConstants.venue)
        XCTAssertEqual(exampleShowInEmulator.addressIsPrivate, exampleShowInTestingConstants.addressIsPrivate)
        XCTAssertEqual(exampleShowInEmulator.bandIds, exampleShowInTestingConstants.bandIds)
        XCTAssertEqual(exampleShowInEmulator.hasBar, exampleShowInTestingConstants.hasBar)
        XCTAssertEqual(exampleShowInEmulator.hasFood, exampleShowInTestingConstants.hasFood)
        XCTAssertEqual(exampleShowInEmulator.is21Plus, exampleShowInTestingConstants.is21Plus)
        XCTAssertEqual(exampleShowInEmulator.isFree, exampleShowInTestingConstants.isFree)
        XCTAssertEqual(exampleShowInEmulator.participantUids, exampleShowInTestingConstants.participantUids)
        XCTAssertEqual(exampleShowInEmulator.ticketSalesAreRequired, exampleShowInTestingConstants.ticketSalesAreRequired)
        XCTAssertEqual(exampleShowInEmulator.loadInTime, exampleShowInTestingConstants.loadInTime)
        XCTAssertEqual(exampleShowInEmulator.doorsTime, exampleShowInTestingConstants.doorsTime)
        XCTAssertEqual(exampleShowInEmulator.musicStartTime, exampleShowInTestingConstants.musicStartTime)
        XCTAssertEqual(exampleShowInEmulator.endTime, exampleShowInTestingConstants.endTime)
    }
    
    func test_OnInit_ExampleShowInFirestoreEmulatorMatchesExampleShowInTestingConstants() async throws {
        let exampleShow = try await testingDatabaseService.getShow(TestingConstants.exampleShowDumpweedExtravaganza)

        XCTAssertEqual(exampleShow, TestingConstants.exampleShowDumpweedExtravaganza)
    }

    // MARK: - Firestore Example Users

    func test_OnInit_ExampleUserJulianInFirestoreEmulatorHasExpectedValues() async throws {
        let julianInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserJulian)
        let julianInTestingConstants = TestingConstants.exampleUserJulian

        XCTAssertEqual(julianInEmulator.id, julianInTestingConstants.id)
        XCTAssertEqual(julianInEmulator.firstName, julianInTestingConstants.firstName)
        XCTAssertEqual(julianInEmulator.lastName, julianInTestingConstants.lastName)
        XCTAssertEqual(julianInEmulator.profileImageUrl, julianInTestingConstants.profileImageUrl)
        XCTAssertEqual(julianInEmulator.username, julianInTestingConstants.username)
        XCTAssertEqual(julianInEmulator.emailAddress, julianInTestingConstants.emailAddress)
        XCTAssertEqual(julianInEmulator.fcmToken, julianInTestingConstants.fcmToken)
        XCTAssertEqual(julianInEmulator.phoneNumber, julianInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUserLouInFirestoreEmulatorHasExpectedValues() async throws {
        let louInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserLou)
        let louInTestingConstants = TestingConstants.exampleUserLou

        XCTAssertEqual(louInEmulator.id, louInTestingConstants.id)
        XCTAssertEqual(louInEmulator.firstName, louInTestingConstants.firstName)
        XCTAssertEqual(louInEmulator.lastName, louInTestingConstants.lastName)
        XCTAssertEqual(louInEmulator.profileImageUrl, louInTestingConstants.profileImageUrl)
        XCTAssertEqual(louInEmulator.username, louInTestingConstants.username)
        XCTAssertEqual(louInEmulator.emailAddress, louInTestingConstants.emailAddress)
        XCTAssertEqual(louInEmulator.fcmToken, louInTestingConstants.fcmToken)
        XCTAssertEqual(louInEmulator.phoneNumber, louInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUserTasInFirestoreEmulatorHasExpectedValues() async throws {
        let tasInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserTas)
        let tasInTestingConstants = TestingConstants.exampleUserTas

        XCTAssertEqual(tasInEmulator.id, tasInTestingConstants.id)
        XCTAssertEqual(tasInEmulator.firstName, tasInTestingConstants.firstName)
        XCTAssertEqual(tasInEmulator.lastName, tasInTestingConstants.lastName)
        XCTAssertEqual(tasInEmulator.profileImageUrl, tasInTestingConstants.profileImageUrl)
        XCTAssertEqual(tasInEmulator.username, tasInTestingConstants.username)
        XCTAssertEqual(tasInEmulator.emailAddress, tasInTestingConstants.emailAddress)
        XCTAssertEqual(tasInEmulator.fcmToken, tasInTestingConstants.fcmToken)
        XCTAssertEqual(tasInEmulator.phoneNumber, tasInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUserEricInFirestoreEmulatorHasExpectedValues() async throws {
        let ericInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserEric)
        let ericInTestingConstants = TestingConstants.exampleUserEric

        XCTAssertEqual(ericInEmulator.id, ericInTestingConstants.id)
        XCTAssertEqual(ericInEmulator.firstName, ericInTestingConstants.firstName)
        XCTAssertEqual(ericInEmulator.lastName, ericInTestingConstants.lastName)
        XCTAssertEqual(ericInEmulator.profileImageUrl, ericInTestingConstants.profileImageUrl)
        XCTAssertEqual(ericInEmulator.username, ericInTestingConstants.username)
        XCTAssertEqual(ericInEmulator.emailAddress, ericInTestingConstants.emailAddress)
        XCTAssertEqual(ericInEmulator.fcmToken, ericInTestingConstants.fcmToken)
        XCTAssertEqual(ericInEmulator.phoneNumber, ericInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUserMikeInFirestoreEmulatorHasExpectedValues() async throws {
        let mikeInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserMike)
        let mikeInTestingConstants = TestingConstants.exampleUserMike

        XCTAssertEqual(mikeInEmulator.id, mikeInTestingConstants.id)
        XCTAssertEqual(mikeInEmulator.firstName, mikeInTestingConstants.firstName)
        XCTAssertEqual(mikeInEmulator.lastName, mikeInTestingConstants.lastName)
        XCTAssertEqual(mikeInEmulator.profileImageUrl, mikeInTestingConstants.profileImageUrl)
        XCTAssertEqual(mikeInEmulator.username, mikeInTestingConstants.username)
        XCTAssertEqual(mikeInEmulator.emailAddress, mikeInTestingConstants.emailAddress)
        XCTAssertEqual(mikeInEmulator.fcmToken, mikeInTestingConstants.fcmToken)
        XCTAssertEqual(mikeInEmulator.phoneNumber, mikeInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUsersInFirestoreEmulatorMatchTestingConstants() async throws {
        let julianInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserJulian)
        let ericInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserEric)
        let louInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserLou)
        let tasInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserTas)
        let mikeInEmulator = try await testingDatabaseService.getUserFromFirestore(TestingConstants.exampleUserMike)

        XCTAssertEqual(julianInEmulator, TestingConstants.exampleUserJulian)
        XCTAssertEqual(ericInEmulator, TestingConstants.exampleUserEric)
        XCTAssertEqual(louInEmulator, TestingConstants.exampleUserLou)
        XCTAssertEqual(tasInEmulator, TestingConstants.exampleUserTas)
        XCTAssertEqual(mikeInEmulator, TestingConstants.exampleUserMike)
    }

    // MARK: - Firestore Example Bands

    func test_OnInit_ExampleBandPatheticFallacyInFirestoreEmulatorHasExpectedValues() async throws {
        let patheticFallacyInEmulator = try await testingDatabaseService.getBand(TestingConstants.exampleBandPatheticFallacy)
        let patheticFallacyInTestingConstants = TestingConstants.exampleBandPatheticFallacy

        XCTAssertEqual(patheticFallacyInEmulator.adminUid, TestingConstants.exampleUserJulian.id)
        XCTAssertEqual(patheticFallacyInEmulator.bio, patheticFallacyInTestingConstants.bio)
        XCTAssertEqual(patheticFallacyInEmulator.city, patheticFallacyInTestingConstants.city)
        XCTAssertEqual(patheticFallacyInEmulator.genre, patheticFallacyInTestingConstants.genre)
        XCTAssertEqual(patheticFallacyInEmulator.id, patheticFallacyInTestingConstants.id)
        XCTAssertEqual(patheticFallacyInEmulator.memberFcmTokens, patheticFallacyInTestingConstants.memberFcmTokens)
        XCTAssertEqual(patheticFallacyInEmulator.memberUids, patheticFallacyInTestingConstants.memberUids)
        XCTAssertEqual(patheticFallacyInEmulator.name, patheticFallacyInTestingConstants.name)
        XCTAssertEqual(patheticFallacyInEmulator.state, patheticFallacyInTestingConstants.state)
    }

    func test_OnInit_ExampleBandDumpweedInFirestoreEmulatorHasExpectedValues() async throws {
        let dumpweedInEmulator = try await testingDatabaseService.getBand(TestingConstants.exampleBandDumpweed)
        let dumpweedInTestingConstants = TestingConstants.exampleBandDumpweed

        XCTAssertEqual(dumpweedInEmulator.adminUid, TestingConstants.exampleUserEric.id)
        XCTAssertEqual(dumpweedInEmulator.bio, dumpweedInTestingConstants.bio)
        XCTAssertEqual(dumpweedInEmulator.city, dumpweedInTestingConstants.city)
        XCTAssertEqual(dumpweedInEmulator.genre, dumpweedInTestingConstants.genre)
        XCTAssertEqual(dumpweedInEmulator.id, dumpweedInTestingConstants.id)
        XCTAssertEqual(dumpweedInEmulator.memberFcmTokens, dumpweedInTestingConstants.memberFcmTokens)
        XCTAssertEqual(dumpweedInEmulator.memberUids, dumpweedInTestingConstants.memberUids)
        XCTAssertEqual(dumpweedInEmulator.name, dumpweedInTestingConstants.name)
        XCTAssertEqual(dumpweedInEmulator.state, dumpweedInTestingConstants.state)
    }

    func test_OnInit_ExampleBandsInFirestoreEmulatorMatchTestingConstants() async throws {
        let patheticFallacyInEmulator = try await testingDatabaseService.getBand(TestingConstants.exampleBandPatheticFallacy)
        let dumpweedInEmulator = try await testingDatabaseService.getBand(TestingConstants.exampleBandDumpweed)

        XCTAssertEqual(patheticFallacyInEmulator, TestingConstants.exampleBandPatheticFallacy)
        XCTAssertEqual(dumpweedInEmulator, TestingConstants.exampleBandDumpweed)
    }

    // MARK: - Firestore Example BandInvites

    func test_OnInit_ExampleBandInviteInFirestoreEmulatorHasExpectedValues() async throws {
        let bandInviteInEmulator = try await testingDatabaseService.getBandInvite(get: TestingConstants.exampleBandInvite, for: TestingConstants.exampleUserTas)
        let bandInviteInTestingConstants = TestingConstants.exampleBandInvite

        XCTAssertEqual(bandInviteInEmulator.id, bandInviteInTestingConstants.id)
        XCTAssertEqual(bandInviteInEmulator.dateSent, bandInviteInTestingConstants.dateSent)
        XCTAssertEqual(bandInviteInEmulator.notificationType, bandInviteInTestingConstants.notificationType)
        XCTAssertEqual(bandInviteInEmulator.recipientUid, TestingConstants.exampleUserTas.id)
        XCTAssertEqual(bandInviteInEmulator.recipientRole, bandInviteInTestingConstants.recipientRole)
        XCTAssertEqual(bandInviteInEmulator.bandId, TestingConstants.exampleBandPatheticFallacy.id)
        XCTAssertEqual(bandInviteInEmulator.senderUsername, TestingConstants.exampleUserJulian.username)
        XCTAssertEqual(bandInviteInEmulator.senderBand, TestingConstants.exampleBandPatheticFallacy.name)
        XCTAssertEqual(
            bandInviteInEmulator.message,
            "\(TestingConstants.exampleUserJulian.username) is inviting you to join \(TestingConstants.exampleBandPatheticFallacy.name)"
        )
    }

    func test_OnInit_ExampleBandInvitesInFirestoreEmulatorMatchTestingConstants() async throws {
        let bandInviteInEmulator = try await testingDatabaseService.getBandInvite(get: TestingConstants.exampleBandInvite, for: TestingConstants.exampleUserTas)

        XCTAssertEqual(bandInviteInEmulator, TestingConstants.exampleBandInvite)
    }

    // MARK: - Firestore Example BandMembers

    func test_OnInit_ExampleBandMemberJulianInFirestoreEmulatorHasExpectedValues() async throws {
        let bandMemberJulianInEmulator = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberJulian,
            in: TestingConstants.exampleBandPatheticFallacy
        )
        let bandMemberJulianInTestingConstants = TestingConstants.exampleBandMemberJulian

        XCTAssertEqual(bandMemberJulianInEmulator.id, bandMemberJulianInTestingConstants.id)
        XCTAssertEqual(bandMemberJulianInEmulator.dateJoined, bandMemberJulianInTestingConstants.dateJoined)
        XCTAssertEqual(bandMemberJulianInEmulator.uid, TestingConstants.exampleUserJulian.id)
        XCTAssertEqual(bandMemberJulianInEmulator.role, bandMemberJulianInTestingConstants.role)
        XCTAssertEqual(bandMemberJulianInEmulator.username, TestingConstants.exampleUserJulian.username)
        XCTAssertEqual(bandMemberJulianInEmulator.fullName, TestingConstants.exampleUserJulian.fullName)
    }

    func test_OnInit_ExampleBandMemberLouInFirestoreEmulatorHasExpectedValues() async throws {
        let bandMemberLouInEmulator = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberLou,
            in: TestingConstants.exampleBandPatheticFallacy
        )
        let bandMemberLouInTestingConstants = TestingConstants.exampleBandMemberLou

        XCTAssertEqual(bandMemberLouInEmulator.id, bandMemberLouInTestingConstants.id)
        XCTAssertEqual(bandMemberLouInEmulator.dateJoined, bandMemberLouInTestingConstants.dateJoined)
        XCTAssertEqual(bandMemberLouInEmulator.uid, TestingConstants.exampleUserLou.id)
        XCTAssertEqual(bandMemberLouInEmulator.role, bandMemberLouInTestingConstants.role)
        XCTAssertEqual(bandMemberLouInEmulator.username, TestingConstants.exampleUserLou.username)
        XCTAssertEqual(bandMemberLouInEmulator.fullName, TestingConstants.exampleUserLou.fullName)
    }

    func test_OnInit_ExampleBandMemberEricInFirestoreEmulatorHasExpectedValues() async throws {
        let bandMemberEricInEmulator = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberEric,
            in: TestingConstants.exampleBandDumpweed
        )
        let bandMemberEricInTestingConstants = TestingConstants.exampleBandMemberEric

        XCTAssertEqual(bandMemberEricInEmulator.id, bandMemberEricInTestingConstants.id)
        XCTAssertEqual(bandMemberEricInEmulator.dateJoined, bandMemberEricInTestingConstants.dateJoined)
        XCTAssertEqual(bandMemberEricInEmulator.uid, TestingConstants.exampleUserEric.id)
        XCTAssertEqual(bandMemberEricInEmulator.role, bandMemberEricInTestingConstants.role)
        XCTAssertEqual(bandMemberEricInEmulator.username, TestingConstants.exampleUserEric.username)
        XCTAssertEqual(bandMemberEricInEmulator.fullName, TestingConstants.exampleUserEric.fullName)
    }

    func test_OnInit_ExampleBandMembersInFirestoreEmulatorMatchTestingConstants() async throws {
        let bandMemberJulianInEmulator = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberJulian,
            in: TestingConstants.exampleBandPatheticFallacy
        )
        let bandMemberLouInEmulator = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberLou,
            in: TestingConstants.exampleBandPatheticFallacy
        )
        let bandMemberEricInEmulator = try await testingDatabaseService.getBandMember(
            get: TestingConstants.exampleBandMemberEric,
            in: TestingConstants.exampleBandDumpweed
        )
        let bandMemberJulianInTestingConstants = TestingConstants.exampleBandMemberJulian
        let bandMemberLouInTestingConstants = TestingConstants.exampleBandMemberLou
        let bandMemberEricInTestingConstants = TestingConstants.exampleBandMemberEric

        XCTAssertEqual(bandMemberJulianInEmulator, bandMemberJulianInTestingConstants)
        XCTAssertEqual(bandMemberLouInEmulator, bandMemberLouInTestingConstants)
        XCTAssertEqual(bandMemberEricInEmulator, bandMemberEricInTestingConstants)
    }

    // MARK: - Firestore Example Chats

    func test_OnInit_ExampleChatDumpweedExtravaganzaInFirestoreEmulatorHasExpectedValues() async throws {
        let chatInEmulator = try await testingDatabaseService.getChat(TestingConstants.exampleChatDumpweedExtravaganza)
        let chatInTestingConstants = TestingConstants.exampleChatDumpweedExtravaganza

        XCTAssertEqual(chatInEmulator.id, chatInTestingConstants.id)
        XCTAssertEqual(chatInEmulator.showId, TestingConstants.exampleShowDumpweedExtravaganza.id)
        XCTAssertEqual(chatInEmulator.name, TestingConstants.exampleShowDumpweedExtravaganza.name)
        XCTAssertEqual(chatInEmulator.participantUids, chatInTestingConstants.participantUids)
        XCTAssertEqual(chatInEmulator.participantFcmTokens, chatInTestingConstants.participantFcmTokens)
        XCTAssertEqual(chatInEmulator.userId, chatInTestingConstants.userId)
    }

    func test_OnInit_ExampleChatsInFirestoreEmulatorMatchTestingConstants() async throws {
        let dumpweedExtravaganzaChatInEmulator = try await testingDatabaseService.getChat(TestingConstants.exampleChatDumpweedExtravaganza)
        let dumpweedExtravaganzaChatInTestingConstants = TestingConstants.exampleChatDumpweedExtravaganza

        XCTAssertEqual(dumpweedExtravaganzaChatInEmulator, dumpweedExtravaganzaChatInTestingConstants)
    }

    // MARK: - Firestore Example ChatMessages

    func test_OnInit_ExampleChatMessageJulianHasExpectedValues() async throws {
        let julianMessageInEmulator = try await testingDatabaseService.getChatMessage(get: TestingConstants.exampleChatMessageJulian, in: TestingConstants.exampleChatDumpweedExtravaganza)
        let julianMessageInTestingConstants = TestingConstants.exampleChatMessageJulian

        XCTAssertEqual(julianMessageInEmulator.recipientFcmTokens, julianMessageInTestingConstants.recipientFcmTokens)
        XCTAssertEqual(julianMessageInEmulator.text, julianMessageInTestingConstants.text)
        XCTAssertEqual(julianMessageInEmulator.id, julianMessageInTestingConstants.id)
        XCTAssertEqual(julianMessageInEmulator.senderUid, julianMessageInTestingConstants.senderUid)
        XCTAssertEqual(julianMessageInEmulator.senderFullName, julianMessageInTestingConstants.senderFullName)
        XCTAssertEqual(julianMessageInEmulator.sentTimestamp, julianMessageInTestingConstants.sentTimestamp)
        XCTAssertEqual(julianMessageInEmulator.recipientFcmTokens, julianMessageInTestingConstants.recipientFcmTokens)
    }

    func test_OnInit_ExampleChatMessageEricHasExpectedValues() async throws {
        let ericMessageInEmulator = try await testingDatabaseService.getChatMessage(get: TestingConstants.exampleChatMessageEric, in: TestingConstants.exampleChatDumpweedExtravaganza)
        let ericMessageInTestingConstants = TestingConstants.exampleChatMessageEric

        XCTAssertEqual(ericMessageInEmulator.recipientFcmTokens, ericMessageInTestingConstants.recipientFcmTokens)
        XCTAssertEqual(ericMessageInEmulator.text, ericMessageInTestingConstants.text)
        XCTAssertEqual(ericMessageInEmulator.id, ericMessageInTestingConstants.id)
        XCTAssertEqual(ericMessageInEmulator.senderUid, ericMessageInTestingConstants.senderUid)
        XCTAssertEqual(ericMessageInEmulator.senderFullName, ericMessageInTestingConstants.senderFullName)
        XCTAssertEqual(ericMessageInEmulator.sentTimestamp, ericMessageInTestingConstants.sentTimestamp)
        XCTAssertEqual(ericMessageInEmulator.recipientFcmTokens, ericMessageInTestingConstants.recipientFcmTokens)
    }

    func test_OnInit_ExampleChatMessagesInFirestoreEmulatorMatchTestingConstants() async throws {
        let julianMessageInEmulator = try await testingDatabaseService.getChatMessage(get: TestingConstants.exampleChatMessageJulian, in: TestingConstants.exampleChatDumpweedExtravaganza)
        let ericMessageInEmulator = try await testingDatabaseService.getChatMessage(get: TestingConstants.exampleChatMessageEric, in: TestingConstants.exampleChatDumpweedExtravaganza)
        let julianMessageInTestingConstants = TestingConstants.exampleChatMessageJulian
        let ericMessageInTestingConstants = TestingConstants.exampleChatMessageEric

        XCTAssertEqual(julianMessageInEmulator, julianMessageInTestingConstants)
        XCTAssertEqual(ericMessageInEmulator, ericMessageInTestingConstants)
    }

    // MARK: - Firebase Auth

    func test_OnInit_FirebaseAuthEmulatorContainsTestAccount() async throws {
        guard let currentUser = try await testingDatabaseService.logInToJulianAccount() else {
            XCTFail("The user should be signed in during setUp before this test is run")
            return
        }

        XCTAssertEqual(currentUser.email, TestingConstants.exampleUserJulian.emailAddress)
        XCTAssertEqual(currentUser.uid, TestingConstants.exampleUserJulian.id)
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
