//
//  NotificationsViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/11/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class NotificationsViewModelTests: XCTestCase {
    var sut: NotificationsViewModel!
    var testingDatabaseService: TestingDatabaseService!
    var createdUserUid: String?
    var createdBandId: String?
    var createdShowInviteId: String?

    override func setUpWithError() throws {
        sut = NotificationsViewModel()
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDown() async throws {
        if let createdShowInviteId {
            try await testingDatabaseService.deleteShowInvite(
                showInviteId: createdShowInviteId,
                forUserWithUid: AuthController.getLoggedInUid()
            )
            self.createdShowInviteId = nil
        }

        if let createdUserUid {
            try await testingDatabaseService.deleteAccountInFirebaseAuthAndFirestore(forUserWithUid: createdUserUid)
            self.createdUserUid = nil
        }

        if let createdBandId {
            try await testingDatabaseService.deleteBand(with: createdBandId)
            self.createdBandId = nil
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertTrue(sut.fetchedNotifications.isEmpty)
        XCTAssertEqual(sut.selectedNotificationType, .bandInvite)
        XCTAssertEqual(sut.viewState, .dataLoading)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
    }

    func test_OnGetNotificationsWhenUserHasNotifications_NotificationsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToTasAccount()
        sut.getNotifications()
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.fetchedNotifications.count, 1, "Tas has one notification")
        XCTAssertEqual(sut.viewState, .dataLoaded, "Data should've been found")
    }

    func test_OnGetNotificationsWhenUserHasNoNotifications_NoNotificationsAreFetchedAndViewStateIsSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut.getNotifications()
        try await Task.sleep(seconds: 2)

        XCTAssertTrue(sut.fetchedNotifications.isEmpty, "Julian has no notifications")
        XCTAssertEqual(sut.viewState, .dataNotFound, "No data should've been found")
    }

    func test_OnNotificationReceived_FetchedNotificationsArrayUpdatesInRealtime() async throws {
        try await testingDatabaseService.logInToMikeAccount()
        let showInvite = try await createGenerationUndergroundAndSendInviteToPlayDumpweedExtravaganza()

        sut.getNotifications()
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.fetchedNotifications.count, 1, "Mike should only have 1 notification at this point")

        self.createdShowInviteId = try testingDatabaseService.sendShowInvite(
            send: showInvite,
            toBandWithAdminUid: TestingConstants.exampleUserMike.id
        )
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.fetchedNotifications.count, 2, "Mike should now have 2 notifications")

        // Cleans up the second sent notification
        try await testingDatabaseService.deleteShowInvite(
            showInviteId: showInvite.id,
            forUserWithUid: TestingConstants.exampleUserMike.id
        )
    }

    func test_OnNotificationReceivedAfterRemovingListener_FetchedNotificationsArrayDoesNotUpdate() async throws {
        try await testingDatabaseService.logInToMikeAccount()
        let showInvite = try await createGenerationUndergroundAndSendInviteToPlayDumpweedExtravaganza()

        sut.getNotifications()
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.fetchedNotifications.count, 1, "Mike should only have 1 notification")

        sut.removeListeners()

        self.createdShowInviteId = try testingDatabaseService.sendShowInvite(
            send: showInvite,
            toBandWithAdminUid: TestingConstants.exampleUserMike.id
        )
        try await Task.sleep(seconds: 2)

        XCTAssertEqual(sut.fetchedNotifications.count, 1, "An additional notification shouldn't have been fetched because the listener was removed")

        // Cleans up the second sent notification
        try await testingDatabaseService.deleteShowInvite(
            showInviteId: showInvite.id,
            forUserWithUid: TestingConstants.exampleUserMike.id
        )
    }

    func test_OnAcceptBandInvite_UserIsAddedToBand() async throws {
        let bandInvite = try await createMattUserAndSendBandInviteToJoinPatheticFallacy()
        let bandInviteAsAnyUserNotification = AnyUserNotification(id: bandInvite.id, notification: bandInvite)

        await sut.handleNotification(
            anyUserNotification: bandInviteAsAnyUserNotification,
            withAction: .accept
        )
        let patheticFallacy = try await testingDatabaseService.getBand(with: TestingConstants.exampleBandPatheticFallacy.id)
        let userExistsInMembersCollection = try await testingDatabaseService.userExistsInMembersCollectionForBand(
            uid: createdUserUid!,
            bandId: patheticFallacy.id
        )
        let patheticFallacyShows = try await testingDatabaseService.getPlayingShows(forBandWithId: patheticFallacy.id)

        XCTAssertTrue(patheticFallacy.memberUids.contains(createdUserUid!), "The user should've been added to the band's memberUids array")
        XCTAssertTrue(userExistsInMembersCollection, "The user should've been added to the band's members collection")
        for show in patheticFallacyShows {
            XCTAssertTrue(show.participantUids.contains(createdUserUid!), "The user should've been added to the band's show's participantUids array")
            let showChat = try await testingDatabaseService.getChat(forShowWithId: show.id)
            XCTAssertTrue(showChat.participantUids.contains(createdUserUid!), "The user should've been added to the chat that belongs to the show that the user's new band is playing")
        }
    }

    func test_OnAcceptBandInvite_InviteIsDeletedFromUserNotifications() async throws {
        let bandInvite = try await createMattUserAndSendBandInviteToJoinPatheticFallacy()
        let bandInviteAsAnyUserNotification = AnyUserNotification(id: bandInvite.id, notification: bandInvite)

        await sut.handleNotification(
            anyUserNotification: bandInviteAsAnyUserNotification,
            withAction: .accept
        )
        let bandInviteNotificationExists = try await testingDatabaseService.notificationExists(forUserWithUid: createdUserUid!, notificationId: bandInvite.id)

        XCTAssertFalse(bandInviteNotificationExists, "The notification should've been deleted from the user's notifications collection after accepting the invite")
    }

    func test_OnDeclinedBandInvite_UserIsNotAddedToBandAndNotificationIsDeleted() async throws {
        let bandInvite = try await createMattUserAndSendBandInviteToJoinPatheticFallacy()
        let bandInviteAsAnyUserNotification = AnyUserNotification(id: bandInvite.id, notification: bandInvite)

        await sut.handleNotification(anyUserNotification: bandInviteAsAnyUserNotification, withAction: .decline)
        let bandInviteNotificationExists = try await testingDatabaseService.notificationExists(
            forUserWithUid: createdUserUid!, notificationId: bandInvite.id
        )
        let patheticFallacy = try await testingDatabaseService.getBand(with: TestingConstants.exampleBandPatheticFallacy.id)
        let userExistsInBandMembersCollection = try await testingDatabaseService.userExistsInMembersCollectionForBand(
            uid: createdUserUid!, bandId: patheticFallacy.id
        )

        XCTAssertFalse(bandInviteNotificationExists, "The notification should've been deleted after the user declined the invite")
        XCTAssertFalse(patheticFallacy.memberUids.contains(createdUserUid!), "The user should not have been added to the band's memberUids array")
        XCTAssertFalse(userExistsInBandMembersCollection, "The user should not have been added to the band's members collection")
    }

    func test_OnAcceptShowInvite_UserAndBandAreAddedToShow() async throws {
        let mike = TestingConstants.exampleUserMike
        try await testingDatabaseService.logInToMikeAccount()
        let showInvite = try await createGenerationUndergroundAndSendInviteToPlayDumpweedExtravaganza()
        let showInviteAsAnyUserNotification = AnyUserNotification(id: showInvite.id, notification: showInvite)

        await sut.handleNotification(anyUserNotification: showInviteAsAnyUserNotification, withAction: .accept)
        let dumpweedExtravaganza = try await testingDatabaseService.getShow(with: TestingConstants.exampleShowDumpweedExtravaganza.id)
        let bandExistsInParticipantsCollection = try await testingDatabaseService.bandExistsInParticipantsCollectionForShow(
            showId: dumpweedExtravaganza.id,
            bandId: createdBandId!
        )
        let chatForDumpweedExtravaganza = try await testingDatabaseService.getChat(forShowWithId: dumpweedExtravaganza.id)

        XCTAssertTrue(chatForDumpweedExtravaganza.participantUids.contains(mike.id), "Mike should be in the show's chat since he was in the band that joined the show")
        XCTAssertTrue(dumpweedExtravaganza.bandIds.contains(createdBandId!), "Generation Underground's id should be in the show's bandIds array")
        XCTAssertTrue(bandExistsInParticipantsCollection, "Generation Underground should be included in the show's participants collection")
    }

    func test_OnAcceptShowInvite_InviteIsDeletedFromUserNotifications() async throws {
        let mike = TestingConstants.exampleUserMike
        try await testingDatabaseService.logInToMikeAccount()
        let showInvite = try await createGenerationUndergroundAndSendInviteToPlayDumpweedExtravaganza()
        let showInviteAsAnyUserNotification = AnyUserNotification(id: showInvite.id, notification: showInvite)

        await sut.handleNotification(anyUserNotification: showInviteAsAnyUserNotification, withAction: .accept)
        let showInviteExists = try await testingDatabaseService.notificationExists(
            forUserWithUid: mike.id,
            notificationId: showInvite.id
        )

        XCTAssertFalse(showInviteExists, "The invite should no longer exist in the user's notifications collection after it was accepted")
    }

    func test_OnDeclineShowInvite_BandIsNotAddedToShowAndNotificationIsDeleted() async throws {
        let mike = TestingConstants.exampleUserMike
        try await testingDatabaseService.logInToMikeAccount()
        let showInvite = try await createGenerationUndergroundAndSendInviteToPlayDumpweedExtravaganza()
        let showInviteAsAnyUserNotification = AnyUserNotification(id: showInvite.id, notification: showInvite)

        await sut.handleNotification(anyUserNotification: showInviteAsAnyUserNotification, withAction: .decline)
        let showInviteExists = try await testingDatabaseService.notificationExists(
            forUserWithUid: mike.id,
            notificationId: showInvite.id
        )
        let dumpweedExtravaganza = try await testingDatabaseService.getShow(with: showInvite.showId)
        let bandExistsInShowParticipantsCollection = try await testingDatabaseService.bandExistsInParticipantsCollectionForShow(
            showId: showInvite.bandId,
            bandId: createdBandId!
        )

        XCTAssertFalse(dumpweedExtravaganza.bandIds.contains(createdBandId!), "Mike declined the invite, so his band shouldn't be playing")
        XCTAssertFalse(bandExistsInShowParticipantsCollection, "Mike declined the invite, so his band shouldn't be playing")
        XCTAssertFalse(showInviteExists, "The notification should've been deleted from Mike's notifications collection after it was declined")

    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertTrue(sut.errorAlertIsShowing, "An alert should be shown when .error is set")
        XCTAssertEqual(sut.errorAlertText, "TEST ERROR", "The error message written above should be shown to the user")
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut.viewState = .displayingView

        XCTAssertTrue(sut.errorAlertIsShowing, "An alert should be shown when an invalid view state is set")
        XCTAssertEqual(sut.errorAlertText, "Invalid ViewState", "The error message should show that an invalid ViewState was set")
    }

    /// A helper method that creates a user, Matt, in Firestore and Firebase Auth, and then sends him an invite to join Pathetic Fallacy.
    ///
    /// Whenever this method is called, a method to delete Matt from Firebase Auth and Firestore should be called afterwards to
    /// clean up Firestore. The notification that's sent to Matt should also be deleted after this method is called if this method is run in a test that doesn't do this already.
    /// - Returns: The BandInvite that is sent to Matt to join Pathetic Fallacy.
    func createMattUserAndSendBandInviteToJoinPatheticFallacy() async throws -> BandInvite {
        let matt = TestingConstants.exampleUserMattForIntegrationTesting
        var mattBandInvite = TestingConstants.exampleBandInviteForMatt
        self.createdUserUid = try await testingDatabaseService.createAccountInFirebaseAuthAndAddNewUserToFirestore(
            emailAddress: matt.emailAddress,
            password: "dynomite",
            username: "mattdiguiseppe",
            firstName: "Matt",
            lastName: "Diguiseppe"
        )
        mattBandInvite.recipientUid = createdUserUid!
        let createdBandInviteId = try testingDatabaseService.sendBandInvite(
            send: mattBandInvite,
            toUserWithUid: createdUserUid!
        )
        var createdBandInvite = try await testingDatabaseService.getBandInvite(
            getBandInviteWithId: createdBandInviteId,
            forUserWithUid: createdUserUid!
        )
        createdBandInvite.id = createdBandInviteId

        return createdBandInvite
    }

    /// A helper method that creates a band, Generation Underground, and adds exampleUserMike to it. Once
    /// this is done, a ShowInvite is sent to Mike, since he's the Generation Underground admin, to join exampleShowDumpweedExtravaganza.
    ///
    /// Whenever this method is called, a method to delete the band should be called afterwards to clean up Firestore. The notification that's sent
    /// to Mike should also be deleted if this method is run in a test that doesn't do this already.
    /// - Returns: The ShowInvite that is sent to Mike for Generation Underground to play Dumpweed Extravaganza.
    func createGenerationUndergroundAndSendInviteToPlayDumpweedExtravaganza() async throws -> ShowInvite {
        let mike = TestingConstants.exampleUserMike
        var mikeShowInvite = TestingConstants.exampleShowInviteForGenerationUnderground
        var generationUnderground = Band(
            id: "",
            name: "Generation Underground",
            bio: "We are so hardcore",
            adminUid: mike.id,
            memberUids: [],
            genre: Genre.rock.rawValue,
            city: "Toms River",
            state: BandState.NJ.rawValue
        )
        self.createdBandId = try await testingDatabaseService.createBand(generationUnderground)
        generationUnderground.id = createdBandId!
        mikeShowInvite.bandId = createdBandId!
        _ = try await testingDatabaseService.addUserToBand(
            add: mike,
            to: generationUnderground,
            forRole: "Vocals"
        )
        let showInviteId = try testingDatabaseService.sendShowInvite(send: mikeShowInvite, toBandWithAdminUid: mike.id)
        var createdShowInvite = try await testingDatabaseService.getShowInvite(
            getShowInviteWithId: showInviteId, forUserWithUid: mike.id
        )
        createdShowInvite.id = showInviteId

        return createdShowInvite
    }
}
