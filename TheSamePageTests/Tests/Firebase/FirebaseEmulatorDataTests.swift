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
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    // MARK: - Firestore Example Users

    func test_OnInit_ExampleUserJulianInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let julianInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserJulian.id)
        let julianInTestingConstants = TestingConstants.exampleUserJulian

        XCTAssertEqual(julianInEmulator.id, julianInTestingConstants.id)
        XCTAssertEqual(julianInEmulator.firstName, julianInTestingConstants.firstName)
        XCTAssertEqual(julianInEmulator.lastName, julianInTestingConstants.lastName)
        XCTAssertEqual(julianInEmulator.profileImageUrl, julianInTestingConstants.profileImageUrl)
        XCTAssertEqual(julianInEmulator.name, julianInTestingConstants.name)
        XCTAssertEqual(julianInEmulator.emailAddress, julianInTestingConstants.emailAddress)
        XCTAssertEqual(julianInEmulator.fcmToken, julianInTestingConstants.fcmToken)
        XCTAssertEqual(julianInEmulator.phoneNumber, julianInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUserLouInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let louInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserLou.id)
        let louInTestingConstants = TestingConstants.exampleUserLou

        XCTAssertEqual(louInEmulator.id, louInTestingConstants.id)
        XCTAssertEqual(louInEmulator.firstName, louInTestingConstants.firstName)
        XCTAssertEqual(louInEmulator.lastName, louInTestingConstants.lastName)
        XCTAssertEqual(louInEmulator.profileImageUrl, louInTestingConstants.profileImageUrl)
        XCTAssertEqual(louInEmulator.name, louInTestingConstants.name)
        XCTAssertEqual(louInEmulator.emailAddress, louInTestingConstants.emailAddress)
        XCTAssertEqual(louInEmulator.fcmToken, louInTestingConstants.fcmToken)
        XCTAssertEqual(louInEmulator.phoneNumber, louInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUserTasInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let tasInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserTas.id)
        let tasInTestingConstants = TestingConstants.exampleUserTas

        XCTAssertEqual(tasInEmulator.id, tasInTestingConstants.id)
        XCTAssertEqual(tasInEmulator.firstName, tasInTestingConstants.firstName)
        XCTAssertEqual(tasInEmulator.lastName, tasInTestingConstants.lastName)
        XCTAssertEqual(tasInEmulator.profileImageUrl, tasInTestingConstants.profileImageUrl)
        XCTAssertEqual(tasInEmulator.name, tasInTestingConstants.name)
        XCTAssertEqual(tasInEmulator.emailAddress, tasInTestingConstants.emailAddress)
        XCTAssertEqual(tasInEmulator.fcmToken, tasInTestingConstants.fcmToken)
        XCTAssertEqual(tasInEmulator.phoneNumber, tasInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUserEricInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let ericInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserEric.id)
        let ericInTestingConstants = TestingConstants.exampleUserEric

        XCTAssertEqual(ericInEmulator.id, ericInTestingConstants.id)
        XCTAssertEqual(ericInEmulator.firstName, ericInTestingConstants.firstName)
        XCTAssertEqual(ericInEmulator.lastName, ericInTestingConstants.lastName)
        XCTAssertEqual(ericInEmulator.profileImageUrl, ericInTestingConstants.profileImageUrl)
        XCTAssertEqual(ericInEmulator.name, ericInTestingConstants.name)
        XCTAssertEqual(ericInEmulator.emailAddress, ericInTestingConstants.emailAddress)
        XCTAssertEqual(ericInEmulator.fcmToken, ericInTestingConstants.fcmToken)
        XCTAssertEqual(ericInEmulator.phoneNumber, ericInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUserMikeInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let mikeInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserMike.id)
        let mikeInTestingConstants = TestingConstants.exampleUserMike

        XCTAssertEqual(mikeInEmulator.id, mikeInTestingConstants.id)
        XCTAssertEqual(mikeInEmulator.firstName, mikeInTestingConstants.firstName)
        XCTAssertEqual(mikeInEmulator.lastName, mikeInTestingConstants.lastName)
        XCTAssertEqual(mikeInEmulator.profileImageUrl, mikeInTestingConstants.profileImageUrl)
        XCTAssertEqual(mikeInEmulator.name, mikeInTestingConstants.name)
        XCTAssertEqual(mikeInEmulator.emailAddress, mikeInTestingConstants.emailAddress)
        XCTAssertEqual(mikeInEmulator.fcmToken, mikeInTestingConstants.fcmToken)
        XCTAssertEqual(mikeInEmulator.phoneNumber, mikeInTestingConstants.phoneNumber)
    }

    func test_OnInit_ExampleUsersInFirestoreEmulatorMatchTestingConstants() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let julianInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserJulian.id)
        let ericInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserEric.id)
        let louInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserLou.id)
        let tasInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserTas.id)
        let mikeInEmulator = try await testingDatabaseService.getUserFromFirestore(withUid: TestingConstants.exampleUserMike.id)

        XCTAssertEqual(julianInEmulator, TestingConstants.exampleUserJulian)
        XCTAssertEqual(ericInEmulator, TestingConstants.exampleUserEric)
        XCTAssertEqual(louInEmulator, TestingConstants.exampleUserLou)
        XCTAssertEqual(tasInEmulator, TestingConstants.exampleUserTas)
        XCTAssertEqual(mikeInEmulator, TestingConstants.exampleUserMike)
    }

    // MARK: - Firestore Example Bands

    func test_OnInit_ExampleBandPatheticFallacyInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let patheticFallacyInEmulator = try await testingDatabaseService.getBand(withId: TestingConstants.exampleBandPatheticFallacy.id)
        let patheticFallacyInTestingConstants = TestingConstants.exampleBandPatheticFallacy

        XCTAssertEqual(patheticFallacyInEmulator.adminUid, patheticFallacyInTestingConstants.adminUid)
        XCTAssertEqual(patheticFallacyInEmulator.bio, patheticFallacyInTestingConstants.bio)
        XCTAssertEqual(patheticFallacyInEmulator.profileImageUrl, patheticFallacyInTestingConstants.profileImageUrl)
        XCTAssertEqual(patheticFallacyInEmulator.city, patheticFallacyInTestingConstants.city)
        XCTAssertEqual(patheticFallacyInEmulator.genre, patheticFallacyInTestingConstants.genre)
        XCTAssertEqual(patheticFallacyInEmulator.id, patheticFallacyInTestingConstants.id)
        XCTAssertEqual(patheticFallacyInEmulator.memberUids, patheticFallacyInTestingConstants.memberUids)
        XCTAssertEqual(patheticFallacyInEmulator.name, patheticFallacyInTestingConstants.name)
        XCTAssertEqual(patheticFallacyInEmulator.state, patheticFallacyInTestingConstants.state)
    }

    func test_OnInit_ExampleBandDumpweedInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let dumpweedInEmulator = try await testingDatabaseService.getBand(withId: TestingConstants.exampleBandDumpweed.id)
        let dumpweedInTestingConstants = TestingConstants.exampleBandDumpweed

        XCTAssertEqual(dumpweedInEmulator.adminUid, dumpweedInTestingConstants.adminUid)
        XCTAssertEqual(dumpweedInEmulator.bio, dumpweedInTestingConstants.bio)
        XCTAssertEqual(dumpweedInEmulator.profileImageUrl, dumpweedInTestingConstants.profileImageUrl)
        XCTAssertEqual(dumpweedInEmulator.city, dumpweedInTestingConstants.city)
        XCTAssertEqual(dumpweedInEmulator.genre, dumpweedInTestingConstants.genre)
        XCTAssertEqual(dumpweedInEmulator.id, dumpweedInTestingConstants.id)
        XCTAssertEqual(dumpweedInEmulator.memberUids, dumpweedInTestingConstants.memberUids)
        XCTAssertEqual(dumpweedInEmulator.name, dumpweedInTestingConstants.name)
        XCTAssertEqual(dumpweedInEmulator.state, dumpweedInTestingConstants.state)
    }

    func test_OnInit_ExampleBandTheApplesInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let theApplesInEmulator = try await testingDatabaseService.getBand(withId: TestingConstants.exampleBandTheApples.id)
        let theApplesInTestingConstants = TestingConstants.exampleBandTheApples

        XCTAssertEqual(theApplesInEmulator.adminUid, theApplesInTestingConstants.adminUid)
        XCTAssertEqual(theApplesInEmulator.bio, theApplesInTestingConstants.bio)
        XCTAssertEqual(theApplesInEmulator.profileImageUrl, theApplesInTestingConstants.profileImageUrl)
        XCTAssertEqual(theApplesInEmulator.city, theApplesInTestingConstants.city)
        XCTAssertEqual(theApplesInEmulator.genre, theApplesInTestingConstants.genre)
        XCTAssertEqual(theApplesInEmulator.id, theApplesInTestingConstants.id)
        XCTAssertEqual(theApplesInEmulator.memberUids, theApplesInTestingConstants.memberUids)
        XCTAssertEqual(theApplesInEmulator.name, theApplesInTestingConstants.name)
        XCTAssertEqual(theApplesInEmulator.state, theApplesInTestingConstants.state)
    }

    func test_OnInit_ExampleBandCraigAndTheFettuccinisInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let craigAndTheFettuccinisInEmulator = try await testingDatabaseService.getBand(withId: TestingConstants.exampleBandCraigAndTheFettuccinis.id)
        let craigAndTheFettuccinisInTestingConstants = TestingConstants.exampleBandCraigAndTheFettuccinis

        XCTAssertEqual(craigAndTheFettuccinisInEmulator.adminUid, craigAndTheFettuccinisInTestingConstants.adminUid)
        XCTAssertEqual(craigAndTheFettuccinisInEmulator.bio, craigAndTheFettuccinisInTestingConstants.bio)
        XCTAssertEqual(craigAndTheFettuccinisInEmulator.profileImageUrl, craigAndTheFettuccinisInTestingConstants.profileImageUrl)
        XCTAssertEqual(craigAndTheFettuccinisInEmulator.city, craigAndTheFettuccinisInTestingConstants.city)
        XCTAssertEqual(craigAndTheFettuccinisInEmulator.genre, craigAndTheFettuccinisInTestingConstants.genre)
        XCTAssertEqual(craigAndTheFettuccinisInEmulator.id, craigAndTheFettuccinisInTestingConstants.id)
        XCTAssertEqual(craigAndTheFettuccinisInEmulator.memberUids, craigAndTheFettuccinisInTestingConstants.memberUids)
        XCTAssertEqual(craigAndTheFettuccinisInEmulator.name, craigAndTheFettuccinisInTestingConstants.name)
        XCTAssertEqual(craigAndTheFettuccinisInEmulator.state, craigAndTheFettuccinisInTestingConstants.state)
    }

    func test_OnInit_ExampleBandsInFirestoreEmulatorMatchTestingConstants() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let patheticFallacyInEmulator = try await testingDatabaseService.getBand(withId: TestingConstants.exampleBandPatheticFallacy.id)
        let dumpweedInEmulator = try await testingDatabaseService.getBand(withId: TestingConstants.exampleBandDumpweed.id)
        let theApplesInEmulator = try await testingDatabaseService.getBand(withId: TestingConstants.exampleBandTheApples.id)
        let craigAndTheFettuccinisInEmulator = try await testingDatabaseService.getBand(withId: TestingConstants.exampleBandCraigAndTheFettuccinis.id)

        XCTAssertEqual(patheticFallacyInEmulator, TestingConstants.exampleBandPatheticFallacy)
        XCTAssertEqual(dumpweedInEmulator, TestingConstants.exampleBandDumpweed)
        XCTAssertEqual(theApplesInEmulator, TestingConstants.exampleBandTheApples)
        XCTAssertEqual(craigAndTheFettuccinisInEmulator, TestingConstants.exampleBandCraigAndTheFettuccinis)
    }

    // MARK: - Firestore Example Shows

    func test_OnInit_ExampleShowDumpweedExtravaganzaInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let exampleShowInEmulator = try await testingDatabaseService.getShow(
            withId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
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
        XCTAssertEqual(exampleShowInEmulator.chatId, exampleShowInTestingConstants.chatId)
    }

    func test_OnInit_ExampleShowAppleParkThrowdownInFirebaseEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let exampleShowInEmulator = try await testingDatabaseService.getShow(
            withId: TestingConstants.exampleShowAppleParkThrowdown.id
        )
        let exampleShowInTestingConstants = TestingConstants.exampleShowAppleParkThrowdown

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
        XCTAssertEqual(exampleShowInEmulator.chatId, exampleShowInTestingConstants.chatId)
    }
    
    func test_OnInit_ExampleShowsInFirestoreEmulatorMatcheExampleShowsInTestingConstants() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let dumpweedExtravaganzaInEmulator = try await testingDatabaseService.getShow(withId: TestingConstants.exampleShowDumpweedExtravaganza.id)
        let dumpweedExtravaganzaInTestingConstants = TestingConstants.exampleShowDumpweedExtravaganza
        let AppleParkThrowdownInEmulator = try await testingDatabaseService.getShow(
            withId: TestingConstants.exampleShowAppleParkThrowdown.id
        )
        let AppleParkThrowdownInTestingConstants = TestingConstants.exampleShowAppleParkThrowdown

        XCTAssertEqual(dumpweedExtravaganzaInEmulator, dumpweedExtravaganzaInTestingConstants)
        XCTAssertEqual(AppleParkThrowdownInEmulator, AppleParkThrowdownInTestingConstants)
    }

    // MARK: - Firestore Example ShowParticipants

    func test_OnInit_ExampleShowParticipantPatheticFallacyInDumpweedExtravaganzaHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let patheticFallacyInEmulator = try await testingDatabaseService.getShowParticipant(
            TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza
        )
        let patheticFallacyInTestingConstants = TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza

        XCTAssertEqual(patheticFallacyInEmulator.id, patheticFallacyInTestingConstants.id)
        XCTAssertEqual(patheticFallacyInEmulator.showId, patheticFallacyInTestingConstants.showId)
        XCTAssertEqual(patheticFallacyInEmulator.bandId, patheticFallacyInTestingConstants.bandId)
        XCTAssertEqual(patheticFallacyInEmulator.bandAdminUid, patheticFallacyInTestingConstants.bandAdminUid)
        XCTAssertEqual(patheticFallacyInEmulator.name, patheticFallacyInTestingConstants.name)
        XCTAssertEqual(patheticFallacyInEmulator.setTime, patheticFallacyInTestingConstants.setTime)
    }

    func test_OnInit_ExampleShowParticipantDumpweedInDumpweedExtravaganzaHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let dumpweedInEmulator = try await testingDatabaseService.getShowParticipant(
            TestingConstants.exampleShowParticipantDumpweedInDumpweedExtravaganza
        )
        let dumpweedInTestingConstants = TestingConstants.exampleShowParticipantDumpweedInDumpweedExtravaganza

        XCTAssertEqual(dumpweedInEmulator.id, dumpweedInTestingConstants.id)
        XCTAssertEqual(dumpweedInEmulator.showId, dumpweedInTestingConstants.showId)
        XCTAssertEqual(dumpweedInEmulator.bandId, dumpweedInTestingConstants.bandId)
        XCTAssertEqual(dumpweedInEmulator.bandAdminUid, dumpweedInTestingConstants.bandAdminUid)
        XCTAssertEqual(dumpweedInEmulator.name, dumpweedInTestingConstants.name)
        XCTAssertEqual(dumpweedInEmulator.setTime, dumpweedInTestingConstants.setTime)

    }

    func test_OnInit_ExampleShowParticipantTheApplesInAppleParkThrowdownHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let theApplesInEmulator = try await testingDatabaseService.getShowParticipant(
            TestingConstants.exampleShowParticipantTheApplesInAppleParkThrowdown
        )
        let theApplesInTestingConstants = TestingConstants.exampleShowParticipantTheApplesInAppleParkThrowdown

        XCTAssertEqual(theApplesInEmulator.id, theApplesInTestingConstants.id)
        XCTAssertEqual(theApplesInEmulator.showId, theApplesInTestingConstants.showId)
        XCTAssertEqual(theApplesInEmulator.bandId, theApplesInTestingConstants.bandId)
        XCTAssertEqual(theApplesInEmulator.bandAdminUid, theApplesInTestingConstants.bandAdminUid)
        XCTAssertEqual(theApplesInEmulator.setTime, theApplesInEmulator.setTime)
    }

    func test_OnInit_ExampleShowParticipantsInFirestoreEmulatorMatchTestingConstants() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let patheticFallacyInEmulator = try await testingDatabaseService.getShowParticipant(
            TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza
        )
        let dumpweedInEmulator = try await testingDatabaseService.getShowParticipant(
            TestingConstants.exampleShowParticipantDumpweedInDumpweedExtravaganza
        )
        let theApplesInEmulator = try await testingDatabaseService.getShowParticipant(
            TestingConstants.exampleShowParticipantTheApplesInAppleParkThrowdown
        )
        let patheticFallacyInTestingConstants = TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza
        let dumpweedInTestingConstants = TestingConstants.exampleShowParticipantDumpweedInDumpweedExtravaganza
        let theApplesInTestingConstants = TestingConstants.exampleShowParticipantTheApplesInAppleParkThrowdown

        XCTAssertEqual(patheticFallacyInEmulator, patheticFallacyInTestingConstants)
        XCTAssertEqual(dumpweedInEmulator, dumpweedInTestingConstants)
        XCTAssertEqual(theApplesInEmulator, theApplesInTestingConstants)
    }

    // MARK: - Firestore Example BandInvites

    func test_OnInit_ExampleBandInviteInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToTasAccount()
        let bandInviteInEmulator = try await testingDatabaseService.getBandInvite(
            withId: TestingConstants.exampleBandInviteForTas.id,
            forUserWithUid: TestingConstants.exampleUserTas.id
        )
        let bandInviteInTestingConstants = TestingConstants.exampleBandInviteForTas

        XCTAssertEqual(bandInviteInEmulator.id, bandInviteInTestingConstants.id)
        XCTAssertEqual(bandInviteInEmulator.sentTimestamp, bandInviteInTestingConstants.sentTimestamp)
        XCTAssertEqual(bandInviteInEmulator.notificationType, bandInviteInTestingConstants.notificationType)
        XCTAssertEqual(bandInviteInEmulator.recipientUid, bandInviteInTestingConstants.recipientUid)
        XCTAssertEqual(bandInviteInEmulator.recipientRole, bandInviteInTestingConstants.recipientRole)
        XCTAssertEqual(bandInviteInEmulator.bandId, bandInviteInTestingConstants.bandId)
        XCTAssertEqual(bandInviteInEmulator.senderUsername, bandInviteInTestingConstants.senderUsername)
        XCTAssertEqual(bandInviteInEmulator.senderBand, bandInviteInTestingConstants.senderBand)
        XCTAssertEqual(bandInviteInEmulator.senderUid, bandInviteInTestingConstants.senderUid)
        XCTAssertEqual(
            bandInviteInEmulator.message,
            "\(TestingConstants.exampleUserJulian.name) is inviting you to join \(TestingConstants.exampleBandPatheticFallacy.name)"
        )
    }

    func test_OnInit_ExampleBandInvitesInFirestoreEmulatorMatchTestingConstants() async throws {
        try await testingDatabaseService.logInToTasAccount()
        let bandInviteInEmulator = try await testingDatabaseService.getBandInvite(
            withId: TestingConstants.exampleBandInviteForTas.id,
            forUserWithUid: TestingConstants.exampleUserTas.id
        )

        XCTAssertEqual(bandInviteInEmulator, TestingConstants.exampleBandInviteForTas)
    }

    // MARK: - Firestore Example ShowApplications

    func test_OnInit_ExampleShowApplicationInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let showApplicationInEmulator = try await testingDatabaseService.getShowApplication(
            withId: TestingConstants.exampleShowApplicationForDumpweedExtravaganza.id,
            forUserWithUid: TestingConstants.exampleUserJulian.id
        )
        let showApplicationInTestingConstants = TestingConstants.exampleShowApplicationForDumpweedExtravaganza

        XCTAssertEqual(showApplicationInEmulator.id, showApplicationInTestingConstants.id)
        XCTAssertEqual(showApplicationInEmulator.recipientFcmToken, showApplicationInTestingConstants.recipientFcmToken)
        XCTAssertEqual(showApplicationInEmulator.notificationType, showApplicationInTestingConstants.notificationType)
        XCTAssertEqual(showApplicationInEmulator.senderUid, showApplicationInTestingConstants.senderUid)
        XCTAssertEqual(showApplicationInEmulator.bandName, showApplicationInTestingConstants.bandName)
        XCTAssertEqual(showApplicationInEmulator.message, showApplicationInTestingConstants.message)
        XCTAssertEqual(showApplicationInEmulator.recipientUid, showApplicationInTestingConstants.recipientUid)
        XCTAssertEqual(showApplicationInEmulator.showId, showApplicationInTestingConstants.showId)
        XCTAssertEqual(showApplicationInEmulator.showName, showApplicationInTestingConstants.showName)
        XCTAssertEqual(showApplicationInEmulator.bandId, showApplicationInTestingConstants.bandId)
        XCTAssertEqual(showApplicationInEmulator.sentTimestamp, showApplicationInTestingConstants.sentTimestamp)
    }

    // MARK: - Firestore Example BandMembers

    func test_OnInit_ExampleBandMemberJulianInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let bandMemberJulianInEmulator = try await testingDatabaseService.getBandMember(
            withFullName:  TestingConstants.exampleBandMemberJulian.fullName,
            inBandWithId: TestingConstants.exampleBandPatheticFallacy.id
        )
        let bandMemberJulianInTestingConstants = TestingConstants.exampleBandMemberJulian

        XCTAssertEqual(bandMemberJulianInEmulator.id, bandMemberJulianInTestingConstants.id)
        XCTAssertEqual(bandMemberJulianInEmulator.dateJoined, bandMemberJulianInTestingConstants.dateJoined)
        XCTAssertEqual(bandMemberJulianInEmulator.uid, bandMemberJulianInTestingConstants.uid)
        XCTAssertEqual(bandMemberJulianInEmulator.role, bandMemberJulianInTestingConstants.role)
        XCTAssertEqual(bandMemberJulianInEmulator.username, bandMemberJulianInTestingConstants.username)
        XCTAssertEqual(bandMemberJulianInEmulator.fullName, bandMemberJulianInTestingConstants.fullName)
    }

    func test_OnInit_ExampleBandMemberLouInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let bandMemberLouInEmulator = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleBandMemberLou.fullName,
            inBandWithId: TestingConstants.exampleBandPatheticFallacy.id
        )
        let bandMemberLouInTestingConstants = TestingConstants.exampleBandMemberLou

        XCTAssertEqual(bandMemberLouInEmulator.id, bandMemberLouInTestingConstants.id)
        XCTAssertEqual(bandMemberLouInEmulator.dateJoined, bandMemberLouInTestingConstants.dateJoined)
        XCTAssertEqual(bandMemberLouInEmulator.uid, bandMemberLouInTestingConstants.uid)
        XCTAssertEqual(bandMemberLouInEmulator.role, bandMemberLouInTestingConstants.role)
        XCTAssertEqual(bandMemberLouInEmulator.username, bandMemberLouInTestingConstants.username)
        XCTAssertEqual(bandMemberLouInEmulator.fullName, bandMemberLouInTestingConstants.fullName)
    }

    func test_OnInit_ExampleBandMemberEricInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let bandMemberEricInEmulator = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleBandMemberEric.fullName,
            inBandWithId: TestingConstants.exampleBandDumpweed.id
        )
        let bandMemberEricInTestingConstants = TestingConstants.exampleBandMemberEric

        XCTAssertEqual(bandMemberEricInEmulator.id, bandMemberEricInTestingConstants.id)
        XCTAssertEqual(bandMemberEricInEmulator.dateJoined, bandMemberEricInTestingConstants.dateJoined)
        XCTAssertEqual(bandMemberEricInEmulator.uid, bandMemberEricInTestingConstants.uid)
        XCTAssertEqual(bandMemberEricInEmulator.role, bandMemberEricInTestingConstants.role)
        XCTAssertEqual(bandMemberEricInEmulator.username, bandMemberEricInTestingConstants.username)
        XCTAssertEqual(bandMemberEricInEmulator.fullName, bandMemberEricInTestingConstants.fullName)
    }

    func test_OnInit_ExampleBandMemberCraigInTheApplesInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let bandMemberCraigInEmulator = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleBandMemberCraigInTheApples.fullName,
            inBandWithId: TestingConstants.exampleBandTheApples.id
        )
        let bandMemberCraigInTestingConstants = TestingConstants.exampleBandMemberCraigInTheApples

        XCTAssertEqual(bandMemberCraigInEmulator.id, bandMemberCraigInTestingConstants.id)
        XCTAssertEqual(bandMemberCraigInEmulator.dateJoined, bandMemberCraigInTestingConstants.dateJoined)
        XCTAssertEqual(bandMemberCraigInEmulator.uid, bandMemberCraigInTestingConstants.uid)
        XCTAssertEqual(bandMemberCraigInEmulator.role, bandMemberCraigInTestingConstants.role)
        XCTAssertEqual(bandMemberCraigInEmulator.username, bandMemberCraigInTestingConstants.username)
        XCTAssertEqual(bandMemberCraigInEmulator.fullName, bandMemberCraigInTestingConstants.fullName)
    }

    func test_OnInit_ExampleBandMemberCragInCraigAndTheFettuccinisInFirestoreEmulatorAsExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let bandMemberCraigInEmulator = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleBandMemberCraigInCraigAndTheFettuccinis.fullName,
            inBandWithId: TestingConstants.exampleBandCraigAndTheFettuccinis.id
        )
        let bandMemberCraigInTestingConstants = TestingConstants.exampleBandMemberCraigInCraigAndTheFettuccinis

        XCTAssertEqual(bandMemberCraigInEmulator.id, bandMemberCraigInTestingConstants.id)
        XCTAssertEqual(bandMemberCraigInEmulator.dateJoined, bandMemberCraigInTestingConstants.dateJoined)
        XCTAssertEqual(bandMemberCraigInEmulator.uid, bandMemberCraigInTestingConstants.uid)
        XCTAssertEqual(bandMemberCraigInEmulator.role, bandMemberCraigInTestingConstants.role)
        XCTAssertEqual(bandMemberCraigInEmulator.username, bandMemberCraigInTestingConstants.username)
        XCTAssertEqual(bandMemberCraigInEmulator.fullName, bandMemberCraigInTestingConstants.fullName)
    }

    func test_OnInit_ExampleBandMembersInFirestoreEmulatorMatchTestingConstants() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let bandMemberJulianInEmulator = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleBandMemberJulian.fullName,
            inBandWithId: TestingConstants.exampleBandPatheticFallacy.id
        )
        let bandMemberLouInEmulator = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleBandMemberLou.fullName,
            inBandWithId: TestingConstants.exampleBandPatheticFallacy.id
        )
        let bandMemberEricInEmulator = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleBandMemberEric.fullName,
            inBandWithId: TestingConstants.exampleBandDumpweed.id
        )
        let bandMemberCraigInTheApplesInEmulator = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleBandMemberCraigInTheApples.fullName,
            inBandWithId: TestingConstants.exampleBandTheApples.id
        )
        let bandMemberCraigInCraigAndTheFettuccinisInEmulator = try await testingDatabaseService.getBandMember(
            withFullName: TestingConstants.exampleBandMemberCraigInCraigAndTheFettuccinis.fullName,
            inBandWithId: TestingConstants.exampleBandCraigAndTheFettuccinis.id
        )
        let bandMemberJulianInTestingConstants = TestingConstants.exampleBandMemberJulian
        let bandMemberLouInTestingConstants = TestingConstants.exampleBandMemberLou
        let bandMemberEricInTestingConstants = TestingConstants.exampleBandMemberEric
        let bandMemberCraigInTheApplesInTestingConstants = TestingConstants.exampleBandMemberCraigInTheApples
        let bandMemberCraigInCraigAndTheFettuccinisInTestingConstants = TestingConstants.exampleBandMemberCraigInCraigAndTheFettuccinis

        XCTAssertEqual(bandMemberJulianInEmulator, bandMemberJulianInTestingConstants)
        XCTAssertEqual(bandMemberLouInEmulator, bandMemberLouInTestingConstants)
        XCTAssertEqual(bandMemberEricInEmulator, bandMemberEricInTestingConstants)
        XCTAssertEqual(bandMemberCraigInTheApplesInEmulator, bandMemberCraigInTheApplesInTestingConstants)
        XCTAssertEqual(bandMemberCraigInCraigAndTheFettuccinisInEmulator, bandMemberCraigInCraigAndTheFettuccinisInTestingConstants)

    }

    // MARK: - Firestore Example Chats

    func test_OnInit_ExampleChatDumpweedExtravaganzaInFirestoreEmulatorHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let chatInEmulator = try await testingDatabaseService.getChat(withId: dumpweedExtravaganza.chatId!)
        let chatInTestingConstants = TestingConstants.exampleChatDumpweedExtravaganza

        XCTAssertEqual(chatInEmulator.id, chatInTestingConstants.id)
        XCTAssertEqual(chatInEmulator.showId, TestingConstants.exampleShowDumpweedExtravaganza.id)
        XCTAssertEqual(chatInEmulator.name, TestingConstants.exampleShowDumpweedExtravaganza.name)
        XCTAssertEqual(chatInEmulator.participantUids, chatInTestingConstants.participantUids)
        XCTAssertEqual(chatInEmulator.participantUsernames, chatInTestingConstants.participantUsernames)
        XCTAssertEqual(chatInEmulator.upToDateParticipantUids, chatInTestingConstants.upToDateParticipantUids)
        XCTAssertEqual(chatInEmulator.mostRecentMessageSenderUsername, chatInTestingConstants.mostRecentMessageSenderUsername)
        XCTAssertEqual(chatInEmulator.mostRecentMessageText, chatInTestingConstants.mostRecentMessageText)
        XCTAssertEqual(chatInEmulator.mostRecentMessageTimestamp, chatInTestingConstants.mostRecentMessageTimestamp)
    }

    func test_OnInit_ExampleChatsInFirestoreEmulatorMatchTestingConstants() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let dumpweedExtravaganzaChatInEmulator = try await testingDatabaseService.getChat(withId: dumpweedExtravaganza.chatId!)
        let dumpweedExtravaganzaChatInTestingConstants = TestingConstants.exampleChatDumpweedExtravaganza

        XCTAssertEqual(dumpweedExtravaganzaChatInEmulator, dumpweedExtravaganzaChatInTestingConstants)
    }

    // MARK: - Firestore Example PlatformLinks

    func test_OnInit_ExamplePlatformLinkPatheticFallacyInstagramHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let instagramLinkInEmulator = try await testingDatabaseService.getPlatformLink(
            get: TestingConstants.examplePlatformLinkPatheticFallacyInstagram,
            for: TestingConstants.exampleBandPatheticFallacy
        )
        let instagramLinkInTestingConstants = TestingConstants.examplePlatformLinkPatheticFallacyInstagram

        XCTAssertEqual(instagramLinkInEmulator.id, instagramLinkInTestingConstants.id)
        XCTAssertEqual(instagramLinkInEmulator.platformName, instagramLinkInTestingConstants.platformName)
        XCTAssertEqual(instagramLinkInEmulator.url, instagramLinkInTestingConstants.url)
    }

    func test_OnInit_ExamplePlatformLinkPatheticFallacyFacebookHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let facebookLinkInEmulator = try await testingDatabaseService.getPlatformLink(
            get: TestingConstants.examplePlatformLinkPatheticFallacyFacebook,
            for: TestingConstants.exampleBandPatheticFallacy
        )
        let facebookLinkInTestingConstants = TestingConstants.examplePlatformLinkPatheticFallacyFacebook

        XCTAssertEqual(facebookLinkInEmulator.id, facebookLinkInTestingConstants.id)
        XCTAssertEqual(facebookLinkInEmulator.platformName, facebookLinkInTestingConstants.platformName)
        XCTAssertEqual(facebookLinkInEmulator.url, facebookLinkInTestingConstants.url)
    }

    func test_OnInit_ExamplePlatformLinksInFirestoreEmulatorMatchTestingConstants() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let instagramLinkInEmulator = try await testingDatabaseService.getPlatformLink(
            get: TestingConstants.examplePlatformLinkPatheticFallacyInstagram,
            for: TestingConstants.exampleBandPatheticFallacy
        )
        let facebookLinkInEmulator = try await testingDatabaseService.getPlatformLink(
            get: TestingConstants.examplePlatformLinkPatheticFallacyFacebook,
            for: TestingConstants.exampleBandPatheticFallacy
        )
        let instagramLinkInTestingConstants = TestingConstants.examplePlatformLinkPatheticFallacyInstagram
        let facebookLinkInTestingConstants = TestingConstants.examplePlatformLinkPatheticFallacyFacebook

        XCTAssertEqual(instagramLinkInEmulator, instagramLinkInTestingConstants)
        XCTAssertEqual(facebookLinkInEmulator, facebookLinkInTestingConstants)
    }

    // MARK: - Firestore Example Backline

    func test_OnInit_ExampleElectricGuitarBacklineItemDumpweedExtravaganzaHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let backlineItemInEmulator = try await testingDatabaseService.getBacklineItem(
            withId: TestingConstants.exampleElectricGuitarBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let backlineItemInTestingConstants = TestingConstants.exampleElectricGuitarBacklineItemDumpweedExtravaganza

        XCTAssertEqual(backlineItemInEmulator.id, backlineItemInTestingConstants.id)
        XCTAssertEqual(backlineItemInEmulator.backlinerUid, backlineItemInTestingConstants.backlinerUid)
        XCTAssertEqual(backlineItemInEmulator.backlinerFullName, backlineItemInTestingConstants.backlinerFullName)
        XCTAssertEqual(backlineItemInEmulator.backlinerUsername, backlineItemInTestingConstants.backlinerUsername)
        XCTAssertEqual(backlineItemInEmulator.type, backlineItemInTestingConstants.type)
        XCTAssertEqual(backlineItemInEmulator.name, backlineItemInTestingConstants.name)
        XCTAssertEqual(backlineItemInEmulator.notes, backlineItemInTestingConstants.notes)
    }

    func test_OnInit_ExampleBassGuitarBacklineItemDumpweedExtravaganzaHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let backlineItemInEmulator = try await testingDatabaseService.getBacklineItem(
            withId: TestingConstants.exampleBassGuitarBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let backlineItemInTestingConstants = TestingConstants.exampleBassGuitarBacklineItemDumpweedExtravaganza

        XCTAssertEqual(backlineItemInEmulator.id, backlineItemInTestingConstants.id)
        XCTAssertEqual(backlineItemInEmulator.backlinerUid, backlineItemInTestingConstants.backlinerUid)
        XCTAssertEqual(backlineItemInEmulator.backlinerFullName, backlineItemInTestingConstants.backlinerFullName)
        XCTAssertEqual(backlineItemInEmulator.backlinerUsername, backlineItemInTestingConstants.backlinerUsername)
        XCTAssertEqual(backlineItemInEmulator.type, backlineItemInTestingConstants.type)
        XCTAssertEqual(backlineItemInEmulator.name, backlineItemInTestingConstants.name)
        XCTAssertEqual(backlineItemInEmulator.notes, backlineItemInTestingConstants.notes)
    }

    func test_OnInit_ExampleAuxPercussionBacklineItemDumpweedExtravaganzaHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let backlineItemInEmulator = try await testingDatabaseService.getBacklineItem(
            withId: TestingConstants.exampleAuxPercussionBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let backlineItemInTestingConstants = TestingConstants.exampleAuxPercussionBacklineItemDumpweedExtravaganza

        XCTAssertEqual(backlineItemInEmulator.id, backlineItemInTestingConstants.id)
        XCTAssertEqual(backlineItemInEmulator.backlinerUid, backlineItemInTestingConstants.backlinerUid)
        XCTAssertEqual(backlineItemInEmulator.backlinerFullName, backlineItemInTestingConstants.backlinerFullName)
        XCTAssertEqual(backlineItemInEmulator.backlinerUsername, backlineItemInTestingConstants.backlinerUsername)
        XCTAssertEqual(backlineItemInEmulator.type, backlineItemInTestingConstants.type)
        XCTAssertEqual(backlineItemInEmulator.name, backlineItemInTestingConstants.name)
        XCTAssertEqual(backlineItemInEmulator.notes, backlineItemInTestingConstants.notes)
    }

    func test_OnInit_ExampleDrumKitPieceBacklineItemDumpweedExtravaganzaHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let backlineItemInEmulator = try await testingDatabaseService.getBacklineItem(
            withId: TestingConstants.exampleDrumKitPieceBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let backlineItemInTestingConstants = TestingConstants.exampleDrumKitPieceBacklineItemDumpweedExtravaganza

        XCTAssertEqual(backlineItemInEmulator.id, backlineItemInTestingConstants.id)
        XCTAssertEqual(backlineItemInEmulator.backlinerUid, backlineItemInTestingConstants.backlinerUid)
        XCTAssertEqual(backlineItemInEmulator.backlinerFullName, backlineItemInTestingConstants.backlinerFullName)
        XCTAssertEqual(backlineItemInEmulator.backlinerUsername, backlineItemInTestingConstants.backlinerUsername)
        XCTAssertEqual(backlineItemInEmulator.type, backlineItemInTestingConstants.type)
        XCTAssertEqual(backlineItemInEmulator.name, backlineItemInTestingConstants.name)
        XCTAssertEqual(backlineItemInEmulator.notes, backlineItemInTestingConstants.notes)
    }

    func test_OnInit_ExampleDrumKitBacklineItemDumpweedExtravaganzaHasExpectedValues() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let backlineItemInEmulator = try await testingDatabaseService.getDrumKitBacklineItem(
            withId: TestingConstants.exampleDrumKitBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let backlineItemInTestingConstants = TestingConstants.exampleDrumKitBacklineItemDumpweedExtravaganza

        XCTAssertEqual(backlineItemInEmulator.id, backlineItemInTestingConstants.id)
        XCTAssertEqual(backlineItemInEmulator.backlinerUid, backlineItemInTestingConstants.backlinerUid)
        XCTAssertEqual(backlineItemInEmulator.backlinerFullName, backlineItemInTestingConstants.backlinerFullName)
        XCTAssertEqual(backlineItemInEmulator.backlinerUsername, backlineItemInTestingConstants.backlinerUsername)
        XCTAssertEqual(backlineItemInEmulator.type, backlineItemInTestingConstants.type)
        XCTAssertEqual(backlineItemInEmulator.name, backlineItemInTestingConstants.name)
        XCTAssertEqual(backlineItemInEmulator.notes, backlineItemInTestingConstants.notes)
        XCTAssertEqual(backlineItemInEmulator.includedKitPieces, backlineItemInTestingConstants.includedKitPieces)
    }

    func test_OnInit_ExampleBacklineInFirestoreEmulatorMatchTestingConstants() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        let exampleElectricGuitarBacklineItemDumpweedExtravaganzaInEmulator = try await testingDatabaseService.getBacklineItem(
            withId: TestingConstants.exampleElectricGuitarBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let exampleBassGuitarBacklineItemDumpweedExtravaganzaInEmulator = try await testingDatabaseService.getBacklineItem(
            withId: TestingConstants.exampleBassGuitarBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let exampleDrumKitBacklineItemDumpweedExtravaganzaInEmulator = try await testingDatabaseService.getDrumKitBacklineItem(
            withId: TestingConstants.exampleDrumKitBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let exampleAuxPercussionBacklineItemDumpweedExtravaganzaInEmulator = try await testingDatabaseService.getBacklineItem(
            withId: TestingConstants.exampleAuxPercussionBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let exampleDrumKitPieceBacklineItemDumpweedExtravaganzaInEmulator = try await testingDatabaseService.getBacklineItem(
            withId: TestingConstants.exampleDrumKitPieceBacklineItemDumpweedExtravaganza.id!,
            inShowWithId: TestingConstants.exampleShowDumpweedExtravaganza.id
        )
        let exampleElectricGuitarBacklineItemDumpweedExtravaganzaInTestingConstants = TestingConstants.exampleElectricGuitarBacklineItemDumpweedExtravaganza
        let exampleBassGuitarBacklineItemDumpweedExtravaganzaInTestingConstants = TestingConstants.exampleBassGuitarBacklineItemDumpweedExtravaganza
        let exampleDrumKitBacklineItemDumpweedExtravaganzaInTestingConstants = TestingConstants.exampleDrumKitBacklineItemDumpweedExtravaganza
        let exampleAuxPercussionBacklineItemDumpweedExtravaganzaInTestingConstants = TestingConstants.exampleAuxPercussionBacklineItemDumpweedExtravaganza
        let exampleDrumKitPieceBacklineItemDumpweedExtravaganzaInTestingConstants = TestingConstants.exampleDrumKitPieceBacklineItemDumpweedExtravaganza

        XCTAssertEqual(exampleElectricGuitarBacklineItemDumpweedExtravaganzaInEmulator, exampleElectricGuitarBacklineItemDumpweedExtravaganzaInTestingConstants)
        XCTAssertEqual(exampleBassGuitarBacklineItemDumpweedExtravaganzaInEmulator, exampleBassGuitarBacklineItemDumpweedExtravaganzaInTestingConstants)
        XCTAssertEqual(exampleDrumKitBacklineItemDumpweedExtravaganzaInEmulator, exampleDrumKitBacklineItemDumpweedExtravaganzaInTestingConstants)
        XCTAssertEqual(exampleAuxPercussionBacklineItemDumpweedExtravaganzaInEmulator, exampleAuxPercussionBacklineItemDumpweedExtravaganzaInTestingConstants)
        XCTAssertEqual(exampleDrumKitPieceBacklineItemDumpweedExtravaganzaInEmulator, exampleDrumKitPieceBacklineItemDumpweedExtravaganzaInTestingConstants)
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

    func test_OnLogIn_CurrentUserExists() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertTrue(testingDatabaseService.userIsLoggedIn(), "The user should've been signed in during setUp before this test was run")
    }

    func test_OnLogOut_FirebaseAuthEmulatorLogsOutUser() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        XCTAssertNotNil(testingDatabaseService.getLoggedInUserFromFirebaseAuth(), "The user should've been signed in during setUp before this test was run")

        try testingDatabaseService.logOut()

        XCTAssertNil(testingDatabaseService.getLoggedInUserFromFirebaseAuth(), "The user should be logged out")
    }

    // MARK: - Firebase Storage

    func test_OnInit_FirebaseStorageEmulatorContainsExampleUserProfileImage() async throws {
        try await testingDatabaseService.logInToJulianAccount()

        let profileImageUrl = try await testingDatabaseService.getDownloadLinkForImage(
            at: TestingConstants.exampleUserJulian.profileImageUrl
        )

        XCTAssertEqual(profileImageUrl, TestingConstants.exampleUserJulian.profileImageUrl)
    }
}
