//
//  TestingDatabaseService.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/17/22.
//

import MapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage
import Foundation

/// Contains various methods and test types designed to only be used for testing.
/// TestingDatabaseService allows for simple communication with Firebase Emulator without
/// the need for adding  methods to DatabaseService that are not meant to be used in production.
class TestingDatabaseService {
    enum TestingDatabaseServiceError: Error {
        case firebaseAuth(message: String)
        case firebaseStorage(message: String)
        case firestore(message: String)
        case decode(message: String)
        case unexpectedNilValue(value: String)
    }
    
    static let shared = TestingDatabaseService()
    
    let db = Firestore.firestore()

    // MARK: - Firestore Users

    func createUserInFirestore(_ user: User) throws -> String {
        return try db
            .collection(FbConstants.users)
            .addDocument(from: user)
            .documentID
    }

    func getUserFromFirestore(withUid uid: String) async throws -> User {
        return try await db
            .collection(FbConstants.users)
            .document(uid)
            .getDocument(as: User.self)
    }

    func createExampleUserWithProfileImageInFirestore(withUser user: User) async throws -> String {
        let profileImageUrl = try await uploadImage(UIImage(systemName: "plus")!)
        var userCopy = user
        userCopy.profileImageUrl = profileImageUrl

        let docRef = try db
            .collection(FbConstants.users)
            .addDocument(from: userCopy)

        return docRef.documentID
    }

    func deleteUserFromFirestore(withUid uid: String) async throws {
        _ = try await Functions.functions().httpsCallable(FbConstants.recursiveDelete).call([FbConstants.path: "\(FbConstants.users)/\(uid)"])

        let userShows = try await getPlayingShows(forUserWithUid: uid)
        for show in userShows {
            try await removeUserFromShow(uid: uid, showId: show.id)
        }

        let userChats = try await getChats(forUserWithUid: uid)
        for chat in userChats {
            try await removeUserFromChat(uid: uid, chatId: chat.id)
        }

        let userBands = try await getBands(forUserWithUid: uid)
        for band in userBands {
            try await removeUserFromBand(uid: uid, bandId: band.id)
        }
    }

    func editUserInfo(uid: String, field: String, newValue: String) async throws {
        try await db
            .collection(FbConstants.users)
            .document(uid)
            .updateData([field: newValue])
    }

    // MARK: - Firestore Shows



    func restoreShow(_ show: Show) async throws {
        try db
            .collection(FbConstants.shows)
            .document(show.id)
            .setData(from: show)
    }

    func getShow(withId id: String) async throws -> Show {
        do {
            return try await db
                .collection(FbConstants.shows)
                .document(id)
                .getDocument(as: Show.self)
        }
    }

    func editShow(showId: String, field: String, newValue: Any) async throws {
        try await db
            .collection(FbConstants.shows)
            .document(showId)
            .updateData([field: newValue])
    }

    func getPlayingShows(forUserWithUid uid: String) async throws -> [Show] {
        let showDocuments = try await db
            .collection(FbConstants.shows)
            .whereField(FbConstants.participantUids, arrayContains: uid)
            .getDocuments()
            .documents

        return try showDocuments.map { try $0.data(as: Show.self) }
    }

    func getPlayingShows(forBandWithId id: String) async throws -> [Show] {
        let showDocuments = try await db
            .collection(FbConstants.shows)
            .whereField(FbConstants.bandIds, arrayContains: id)
            .getDocuments()
            .documents

        return try showDocuments.map { try $0.data(as: Show.self) }
    }

    func createShow(_ show: Show) async throws -> String {
        let showDocument = try db
            .collection(FbConstants.shows)
            .addDocument(from: show)
        try await showDocument.updateData([FbConstants.id: showDocument.documentID])
        return showDocument.documentID
    }

    func updateShowName(showId: String, newName: String) async throws {
        try await db
            .collection(FbConstants.shows)
            .document(showId)
            .updateData([FbConstants.name: newName])
    }

    func addUserToShow(showId: String, uid: String) async throws {
        try await db
            .collection(FbConstants.shows)
            .document(showId)
            .updateData([FbConstants.participantUids: FieldValue.arrayUnion([uid])])
    }

    func createShowWithImage(_ show: Show) async throws -> String {
        let imageUrl = try await uploadImage(UIImage(systemName: "plus")!)
        var showCopy = show
        showCopy.imageUrl = imageUrl

        let docRef = try db
            .collection(FbConstants.shows)
            .addDocument(from: showCopy)

        return docRef.documentID
    }

    func showExists(_ show: Show) async throws -> Bool {
        do {
            return try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .getDocument()
                .exists
        } catch {
            throw TestingDatabaseServiceError.firestore(message: "Failed to determine if show exists in DatabaseService.showExists(show:) Error: \(error.localizedDescription)")
        }
    }

    /// A convenience method for testing that allows for a show document to be deleted. This method is for testing and
    /// should not be used in production, as it does not account for any subcollections a document may have.
    /// - Parameter showId: The document ID of the show to be deleted.
    func deleteShow(withId id: String) async throws {
        do {
            _ = try await Functions.functions().httpsCallable(FbConstants.recursiveDelete).call([FbConstants.path: "\(FbConstants.shows)/\(id)"])
        } catch {
            throw TestingDatabaseServiceError.firestore(message: "Failed to delete show in DatabaseService.deleteShowObject(showId:) Error \(error.localizedDescription)")
        }
    }

    func removeUserFromShow(uid: String, showId: String) async throws {
        try await db
            .collection(FbConstants.shows)
            .document(showId)
            .updateData([FbConstants.participantUids: FieldValue.arrayRemove([uid])])
    }

    func addBandToShow(add band: Band, as showParticipant: ShowParticipant, to show: Show) async throws -> String {
        do {
            // Add showParticipant to the show's participants collection
            let showParticipantDocument = try db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection(FbConstants.participants)
                .addDocument(from: showParticipant)

            // Add the band's ID to the show's bandIds property
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([FbConstants.bandIds: FieldValue.arrayUnion([band.id])])

            if !band.memberUids.isEmpty {
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(
                        [
                            FbConstants.participantUids: FieldValue.arrayUnion(band.memberUids)
                        ]
                    )
                try await addBandToChat(band: band, showId: show.id)
            }

            // Check to see if the band admin is already in the memberUids array. If it isn't, add it to the show's participantUids property.
            if !band.memberUids.contains(band.adminUid) {
                let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData([FbConstants.participantUids: FieldValue.arrayUnion([band.adminUid])])
                try await addUserToChat(user: loggedInUser, showId: show.id)
            }

            return showParticipantDocument.documentID
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(band.name) to \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }

    func removeBandFromShow(bandId: String, showId: String) async throws {
        try await db
            .collection(FbConstants.shows)
            .document(showId)
            .updateData([FbConstants.bandIds: FieldValue.arrayRemove([bandId])])

        let showParticipantDocument = try await db
            .collection(FbConstants.shows)
            .document(showId)
            .collection(FbConstants.participants)
            .whereField(FbConstants.bandId, isEqualTo: bandId)
            .getDocuments()
            .documents
            .first!

        try await db
            .collection(FbConstants.shows)
            .document(showId)
            .collection(FbConstants.participants)
            .document(showParticipantDocument.documentID)
            .delete()
    }

    func restoreExampleShowData(withDataIn show: Show) throws {
        try db
            .collection(FbConstants.shows)
            .document(show.id)
            .setData(from: show)
    }

    // MARK: - Firestore ShowParticipants

    func getShowParticipant(_ showParticipant: ShowParticipant) async throws -> ShowParticipant {
        return try await db
            .collection(FbConstants.shows)
            .document(showParticipant.showId)
            .collection(FbConstants.participants)
            .document(showParticipant.id!)
            .getDocument(as: ShowParticipant.self)
    }

    // MARK: - Firestore Bands

    func createBand(_ band: Band) async throws -> String {
        let bandDocument = try db
            .collection(FbConstants.bands)
            .addDocument(from: band)

        let bandDocumentId = bandDocument.documentID
        try await bandDocument.updateData([FbConstants.id: bandDocumentId])
        return bandDocumentId
    }

    func createBandWithProfileImage(_ band: Band) async throws -> String {
        let profileImageUrl = try await uploadImage(UIImage(systemName: "plus")!)
        var bandCopy = band
        bandCopy.profileImageUrl = profileImageUrl

        let docRef = try db
            .collection(FbConstants.bands)
            .addDocument(from: bandCopy)

        try await docRef.updateData([FbConstants.id: docRef.documentID])
        return docRef.documentID
    }

    func editBandInfo(bandId: String, field: String, newValue: String) async throws {
        try await db
            .collection(FbConstants.bands)
            .document(bandId)
            .updateData([field: newValue])
    }

    func getBand(withId id: String) async throws -> Band {
        return try await db
            .collection(FbConstants.bands)
            .document(id)
            .getDocument(as: Band.self)
    }

    func getBands(forUserWithUid uid: String) async throws -> [Band] {
        let bandDocuments = try await db
            .collection(FbConstants.bands)
            .whereField(FbConstants.memberUids, arrayContains: uid)
            .getDocuments()
            .documents

        return try bandDocuments.map { try $0.data(as: Band.self) }
    }

    func updateBandName(bandId: String, newName: String) async throws {
        try await db
            .collection(FbConstants.bands)
            .document(bandId)
            .updateData([FbConstants.name: newName])
    }

    func deleteBand(with id: String) async throws {
        let bandMembers = try await getAllBandMembers(forBandWithId: id)
        let bandShows = try await getPlayingShows(forBandWithId: id)

        for show in bandShows {
            let chat = try await getChat(forShowWithId: show.id)

            for member in bandMembers {
                try await removeUserFromChat(uid: member.uid, chatId: chat!.id)
                try await removeUserFromShow(uid: member.uid, showId: show.id)
            }

            try await removeBandFromShow(bandId: id, showId: show.id)
        }

        _ = try await Functions.functions().httpsCallable(FbConstants.recursiveDelete).call([FbConstants.path: "\(FbConstants.bands)/\(id)"])
    }

    func addUserToBand(add user: User, to band: Band, forRole role: String) async throws -> String {
        try await db
            .collection(FbConstants.bands)
            .document(band.id)
            .updateData([FbConstants.memberUids: FieldValue.arrayUnion([user.id])])

        let bandMember = BandMember(
            id: "",
            dateJoined: Date.now.timeIntervalSince1970,
            uid: user.id,
            role: role,
            username: user.name,
            fullName: user.fullName
        )

        let bandMemberDocument = try db
            .collection(FbConstants.bands)
            .document(band.id)
            .collection(FbConstants.members)
            .addDocument(from: bandMember)
        try await bandMemberDocument
            .updateData([FbConstants.id: bandMemberDocument.documentID])
        return bandMemberDocument.documentID
    }

    /// Used for restoring Pathetic Fallacy's members back to their expected values after they've been manipulated during testing.
    /// - Parameters:
    ///   - band: exampleBandPatheticFallacy with its correct values that should be restored.
    ///   - show: exampleShowDumpeedExtravaganza with its correct values that should be restored.
    ///   - chat: exampleChatDumpweedExtravaganza with its correct values that should be restored.
    ///   - bandMember: exampleBandMemberLou with his correct values that should be restored.
    func restorePatheticFallacy(
        band: Band,
        show: Show,
        chat: Chat,
        showParticipant: ShowParticipant? = nil,
        bandMembers: [BandMember],
        links: [PlatformLink] = []
    ) async throws {
        try db
            .collection(FbConstants.bands)
            .document(band.id)
            .setData(from: band)

        try await db
            .collection(FbConstants.chats)
            .document(chat.id)
            .updateData([FbConstants.participantUids: chat.participantUids])

        try await db
            .collection(FbConstants.shows)
            .document(show.id)
            .updateData([FbConstants.participantUids: show.participantUids])

        try await db
            .collection(FbConstants.shows)
            .document(show.id)
            .updateData([FbConstants.bandIds: show.bandIds])

        if let showParticipant {
            _ = try db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection(FbConstants.participants)
                .document(showParticipant.id!)
                .setData(from: showParticipant)
        }

        try await db
            .collection(FbConstants.bands)
            .document(band.id)
            .updateData([FbConstants.memberUids: band.memberUids])

        for bandMember in bandMembers {
            try db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.members)
                .document(bandMember.id)
                .setData(from: bandMember)
        }

        for link in links {
            try db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.links)
                .document(link.id!)
                .setData(from: link)
        }
    }

    func removeUserFromBand(uid: String, bandId: String) async throws {
        try await db
            .collection(FbConstants.bands)
            .document(bandId)
            .updateData([FbConstants.memberUids: FieldValue.arrayRemove([uid])])

        let bandMemberId = try await db
            .collection(FbConstants.bands)
            .document(bandId)
            .collection(FbConstants.members)
            .whereField(FbConstants.uid, isEqualTo: uid)
            .getDocuments()
            .documents
            .first!
            .documentID

        try await db
            .collection(FbConstants.bands)
            .document(bandId)
            .collection(FbConstants.members)
            .document(bandMemberId)
            .delete()
    }

    // MARK: - Firestore BandMembers

    func userExistsInMembersCollectionForBand(uid: String, bandId: String) async throws -> Bool {
        return try await !db
            .collection(FbConstants.bands)
            .document(bandId)
            .collection(FbConstants.members)
            .whereField(FbConstants.uid, isEqualTo: uid)
            .getDocuments()
            .documents
            .isEmpty
    }

    func getBandMember(withFullName bandMemberFullName: String, inBandWithId bandId: String) async throws -> BandMember {
        return try await db
            .collection(FbConstants.bands)
            .document(bandId)
            .collection(FbConstants.members)
            .whereField(FbConstants.fullName, isEqualTo: bandMemberFullName)
            .getDocuments()
            .documents[0]
            .data(as: BandMember.self)
    }

    func deleteBandMember(in bandId: String, with memberId: String) async throws {
        try await db
            .collection(FbConstants.bands)
            .document(bandId)
            .collection(FbConstants.members)
            .document(memberId)
            .delete()
    }

    func getAllBandMembers(forBandWithId bandId: String) async throws -> [BandMember] {
        return try await db
            .collection(FbConstants.bands)
            .document(bandId)
            .collection(FbConstants.members)
            .getDocuments()
            .documents
            .map { try $0.data(as: BandMember.self) }
    }

    // MARK: - Firestore BandInvites

    func getBandInvite(withId id: String, forUserWithUid uid: String) async throws -> BandInvite {
        return try await db
            .collection(FbConstants.users)
            .document(uid)
            .collection(FbConstants.notifications)
            .document(id)
            .getDocument(as: BandInvite.self)
    }

    func sendBandInvite(send bandInvite: BandInvite, toUserWithUid uid: String) throws -> String {
        return try db
            .collection(FbConstants.users)
            .document(uid)
            .collection(FbConstants.notifications)
            .addDocument(from: bandInvite)
            .documentID
    }

    // MARK: - Firestore ShowInvites

    func getShowInvite(withId id: String, forUserWithUid uid: String) async throws -> ShowInvite {
        return try await db
            .collection(FbConstants.users)
            .document(uid)
            .collection(FbConstants.notifications)
            .document(id)
            .getDocument(as: ShowInvite.self)
    }

    func sendShowInvite(send showInvite: ShowInvite, toBandWithAdminUid bandAdminUid: String) throws -> String {
        return try db
            .collection(FbConstants.users)
            .document(bandAdminUid)
            .collection(FbConstants.notifications)
            .addDocument(from: showInvite)
            .documentID
    }

    // MARK: - Firestore ShowApplications

    func getShowApplication(withId id: String, forUserWithUid uid: String) async throws -> ShowApplication {
        return try await db
            .collection(FbConstants.users)
            .document(uid)
            .collection(FbConstants.notifications)
            .document(id)
            .getDocument(as: ShowApplication.self)
    }

    func restoreShowApplication(restore showApplication: ShowApplication, forUserWithUid uid: String) async throws {
        // This call must occur first to create a document that the setData(from:) method can then reference.
        try await db
            .collection(FbConstants.users)
            .document(uid)
            .collection(FbConstants.notifications)
            .document(showApplication.id)
            .setData([:])

        try db
            .collection(FbConstants.users)
            .document(uid)
            .collection(FbConstants.notifications)
            .document(showApplication.id)
            .setData(from: showApplication)
    }

    // MARK: - Firestore ShowParticipants

    func getAllShowParticipants(forShowWithId showId: String) async throws -> [ShowParticipant] {
        return try await db
            .collection(FbConstants.shows)
            .document(showId)
            .collection(FbConstants.participants)
            .getDocuments()
            .documents
            .map { try $0.data(as: ShowParticipant.self) }
    }

    func deleteShowParticipant(withName bandName: String, inShowWithId showId: String) async throws {
        try await db
            .collection(FbConstants.shows)
            .document(showId)
            .collection(FbConstants.participants)
            .whereField(FbConstants.name, isEqualTo: bandName)
            .getDocuments()
            .documents
            .first!
            .reference
            .delete()
    }

    func bandExistsInParticipantsCollectionForShow(showId: String, bandId: String) async throws -> Bool {
        return try await !db
            .collection(FbConstants.shows)
            .document(showId)
            .collection(FbConstants.participants)
            .whereField(FbConstants.bandId, isEqualTo: bandId)
            .getDocuments()
            .documents
            .isEmpty
    }

    func restoreShowParticipant(restore showParticipant: ShowParticipant, in show: Show) throws {
        try db
            .collection(FbConstants.shows)
            .document(show.id)
            .collection(FbConstants.participants)
            .document(showParticipant.id!)
            .setData(from: showParticipant)
    }

    // MARK: - Firestore Chats and ChatMessages

    func getChat(forShowWithId showId: String) async throws -> Chat? {
        guard await chatExists(forShowWithId: showId) else { return nil }

        return try await db
            .collection(FbConstants.chats)
            .whereField(FbConstants.showId, isEqualTo: showId)
            .getDocuments()
            .documents
            .first!
            .data(as: Chat.self)
    }

    func getChat(withId chatId: String) async throws -> Chat? {
        guard await chatExists(withId: chatId) else { return nil }

        return try await db
            .collection(FbConstants.chats)
            .whereField(FbConstants.id, isEqualTo: chatId)
            .getDocuments()
            .documents
            .first!
            .data(as: Chat.self)
    }

    func getChats(forUserWithUid uid: String) async throws -> [Chat] {
        let chatDocuments = try await db
            .collection(FbConstants.chats)
            .whereField(FbConstants.participantUids, arrayContains: uid)
            .getDocuments()
            .documents

        return try chatDocuments.map { try $0.data(as: Chat.self) }
    }

    func restoreChat(_ chat: Chat) async throws {
        try db
            .collection(FbConstants.chats)
            .document(chat.id)
            .setData(from: chat)
    }

    func addUserToChat(chatId: String, uid: String) async throws {
        try await db
            .collection(FbConstants.chats)
            .document(chatId)
            .updateData([FbConstants.participantUids: FieldValue.arrayUnion([uid])])
    }

    func chatExists(forShowWithId id: String) async -> Bool {
        do {
            return try await !db
                .collection(FbConstants.chats)
                .whereField(FbConstants.showId, isEqualTo: id)
                .getDocuments()
                .documents
                .isEmpty
        } catch {
            return false
        }
    }

    func chatExists(withId chatId: String) async -> Bool {
        do {
            return try await !db
                .collection(FbConstants.chats)
                .whereField(FbConstants.id, isEqualTo: chatId)
                .getDocuments()
                .documents
                .isEmpty
        } catch {
            return false
        }
    }
    func addUserToChat(user: User, showId: String) async throws {
        let chatQuery = try await db
            .collection(FbConstants.chats)
            .whereField(FbConstants.showId, isEqualTo: showId)
            .getDocuments()

        guard !chatQuery.documents.isEmpty && chatQuery.documents.count == 1 else { return }

        let chat = try chatQuery.documents[0].data(as: Chat.self)

        try await db
            .collection(FbConstants.chats)
            .document(chat.id)
            .updateData([FbConstants.participantUids: FieldValue.arrayUnion([user.id])])
    }

    func addBandToChat(band: Band, showId: String) async throws {
        let chatQuery = try await db
            .collection(FbConstants.chats)
            .whereField(FbConstants.showId, isEqualTo: showId)
            .getDocuments()

        guard !chatQuery.documents.isEmpty && chatQuery.documents.count == 1 else { return }

        let chat = try chatQuery.documents[0].data(as: Chat.self)
        try await db
            .collection(FbConstants.chats)
            .document(chat.id)
            .updateData([FbConstants.participantUids: FieldValue.arrayUnion(band.memberUids)])
    }

    func deleteChat(withId id: String) async throws {
        _ = try await Functions
            .functions()
            .httpsCallable(FbConstants.recursiveDelete)
            .call([FbConstants.path: "\(FbConstants.chats)/\(id)"])
    }

    func removeUserFromChat(uid: String, chatId: String) async throws {
        try await db
            .collection(FbConstants.chats)
            .document(chatId)
            .updateData([FbConstants.participantUids: FieldValue.arrayRemove([uid])])
    }

    func getTotalChatCountInFirestore() async throws -> Int {
        return try await db
            .collection(FbConstants.chats)
            .count
            .getAggregation(source: .server)
            .count as! Int
    }

    func getChatMessage(get chatMessage: ChatMessage, in chat: Chat) async throws -> ChatMessage {
        return try await db
            .collection(FbConstants.chats)
            .document(chat.id)
            .collection(FbConstants.messages)
            .document(chatMessage.id!)
            .getDocument(as: ChatMessage.self)
    }

    func getAllChatMessages(in chat: Chat) async throws -> [ChatMessage] {
        let chatMessageDocuments = try await db
            .collection(FbConstants.chats)
            .document(chat.id)
            .collection(FbConstants.messages)
            .getDocuments()
            .documents

        return try chatMessageDocuments.map { try $0.data(as: ChatMessage.self) }
    }

    func deleteChatMessage(inChatWithId chatId: String, withMessageText messageText: String) async throws {
        let chatMessage = try await db
            .collection(FbConstants.chats)
            .document(chatId)
            .collection(FbConstants.messages)
            .whereField(FbConstants.text, isEqualTo: messageText)
            .getDocuments()
            .documents
            .first!
            .data(as: ChatMessage.self)

        try await db
            .collection(FbConstants.chats)
            .document(chatId)
            .collection(FbConstants.messages)
            .document(chatMessage.id!)
            .delete()
    }

    // MARK: - Firestore Notifications

    func notificationExists(forUserWithUid uid: String, notificationId: String) async throws -> Bool {
        return try await db
            .collection(FbConstants.users)
            .document(uid)
            .collection(FbConstants.notifications)
            .document(notificationId)
            .getDocument()
            .exists
    }

    func deleteNotification(withId id: String, forUserWithUid uid: String) async throws {
        try await db
            .collection(FbConstants.users)
            .document(uid)
            .collection(FbConstants.notifications)
            .document(id)
            .delete()
    }

    // MARK: - Firestore PlatformLinks

    func getPlatformLink(get platformLink: PlatformLink, for band: Band) async throws -> PlatformLink {
        return try await db
            .collection(FbConstants.bands)
            .document(band.id)
            .collection(FbConstants.links)
            .document(platformLink.id!)
            .getDocument(as: PlatformLink.self)
    }

    func restorePlatformLink(restore platformLink: PlatformLink, for band: Band) async throws {
        try db
            .collection(FbConstants.bands)
            .document(band.id)
            .collection(FbConstants.links)
            .document(platformLink.id!)
            .setData(from: platformLink)
    }

    // MARK: - Firestore Backline

    func createBacklineItem(create backlineItem: BacklineItem, in show: Show) async throws {
        try db
            .collection(FbConstants.shows)
            .document(show.id)
            .collection(FbConstants.backlineItems)
            .document(backlineItem.id!)
            .setData(from: backlineItem)
    }

    func createDrumKitBacklineItem(create drumKitBacklineItem: DrumKitBacklineItem, in show: Show) async throws {
        try db
            .collection(FbConstants.shows)
            .document(show.id)
            .collection(FbConstants.backlineItems)
            .document(drumKitBacklineItem.id!)
            .setData(from: drumKitBacklineItem)
    }

    func getBacklineItem(withId backlineItemId: String, inShowWithId showId: String) async throws -> BacklineItem {
        return try await db
            .collection(FbConstants.shows)
            .document(showId)
            .collection(FbConstants.backlineItems)
            .document(backlineItemId)
            .getDocument(as: BacklineItem.self)
    }

    func getDrumKitBacklineItem(withId backlineItemId: String, inShowWithId showId: String) async throws -> DrumKitBacklineItem {
        return try await db
            .collection(FbConstants.shows)
            .document(showId)
            .collection(FbConstants.backlineItems)
            .document(backlineItemId)
            .getDocument(as: DrumKitBacklineItem.self)
    }

    func deleteBacklineItem(withId backlineItemId: String, inShowWithId showId: String) async throws {
        try await db
            .collection(FbConstants.shows)
            .document(showId)
            .collection(FbConstants.backlineItems)
            .document(backlineItemId)
            .delete()
    }

    func getAllBackline(for show: Show) async throws -> [any Backline] {
        do {
            let backlineItemsAsDocumentsArray = try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection(FbConstants.backlineItems)
                .getDocuments()
                .documents

            var backline = [any Backline]()

            for document in backlineItemsAsDocumentsArray {
                if let backlineItem = try? document.data(as: BacklineItem.self) {
                    backline.append(backlineItem)
                } else if let drumKitBacklineItem = try? document.data(as: DrumKitBacklineItem.self) {
                    backline.append(drumKitBacklineItem)
                }
            }

            return backline
        } catch DecodingError.valueNotFound, DecodingError.keyNotFound {
            throw FirebaseError.dataDeleted
        }
    }

    func restoreBackline(_ backline: any Backline, in show: Show) async throws {
        if let backlineItem = backline as? BacklineItem {
            try await createBacklineItem(create: backlineItem, in: show)
        } else if let drumKitBacklineItem = backline as? DrumKitBacklineItem {
            try await createDrumKitBacklineItem(create: drumKitBacklineItem, in: show)
        }
    }

    // MARK: - Firebase Storage

    func uploadImage(_ image: UIImage) async throws -> String? {
        let imageData = image.jpegData(compressionQuality: 0.8)

        guard let imageData else {
            throw LogicError.unexpectedNilValue(
                message: "Failed to upload your image",
                systemError: nil
            )
        }

        let storageRef = Storage.storage().reference()
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        var imageUrl: URL?

        _ = try await fileRef.putDataAsync(imageData)
        let fetchedImageUrl = try await fileRef.downloadURL()
        imageUrl = fetchedImageUrl
        return imageUrl?.absoluteString
    }

    func getDownloadLinkForImage(at url: String?) async throws -> String {
        guard let url else {
            return ""
        }

        let imageRef = Storage.storage().reference(forURL: url)
        return try await imageRef.downloadURL().absoluteString
    }

    func imageExists(at url: String?) async throws -> Bool {
        guard let url else { return false }
        
        let storageReference = Storage.storage().reference(forURL: url)
        let metadata = try await storageReference.getMetadata()

        return metadata.isFile && metadata.size != 0
    }

    func restoreShowForUpdateTesting(show: Show) async throws {
        do {
            try db
                .collection(FbConstants.shows)
                .document(show.id)
                .setData(from: show)
        } catch {
            throw TestingDatabaseServiceError.firestore(message: "Failed to restore show for update testing in TestingDatabaseService.restoreShowForUpdateTesting(show:) Error \(error)")
        }
    }

    func deleteImage(at url: String) async throws {
        let storageRef = Storage.storage().reference(forURL: url)
        try await storageRef.delete()
    }

    // MARK: - Firebase Auth

    func createAccountInFirebaseAuthAndAddNewUserToFirestore(
        emailAddress: String,
        password: String,
        username: String,
        firstName: String,
        lastName: String
    ) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: emailAddress, password: password)
        let uid = result.user.uid

        let newUser = User(
            id: uid,
            name: username,
            firstName: firstName,
            lastName: lastName,
            emailAddress: emailAddress
        )
        try db
            .collection(FbConstants.users)
            .document(uid)
            .setData(from: newUser)

        return uid
    }

    @discardableResult func logInToJulianAccount() async throws -> FirebaseAuth.User? {
        do {
            let result = try await Auth.auth().signIn(withEmail: "julianworden@gmail.com", password: "dynomite")
            return result.user
        } catch {
            return nil
        }
    }

    @discardableResult func logInToLouAccount() async throws -> FirebaseAuth.User? {
        do {
            let result = try await Auth.auth().signIn(withEmail: "lousabba@gmail.com", password: "dynomite")
            return result.user
        } catch {
            return nil
        }
    }

    @discardableResult func logInToTasAccount() async throws -> FirebaseAuth.User? {
        do {
            let result = try await Auth.auth().signIn(withEmail: "tascioppa@gmail.com", password: "dynomite")
            return result.user
        } catch {
            return nil
        }
    }

    @discardableResult func logInToEricAccount() async throws -> FirebaseAuth.User? {
        do {
            let result = try await Auth.auth().signIn(withEmail: "ericpalermo@gmail.com", password: "dynomite")
            return result.user
        } catch {
            return nil
        }
    }

    @discardableResult func logInToMikeAccount() async throws -> FirebaseAuth.User? {
        do {
            let result = try await Auth.auth().signIn(withEmail: "mikeflorentine@gmail.com", password: "dynomite")
            return result.user
        } catch {
            return nil
        }
    }

    @discardableResult func logInToCraigAccount() async throws -> FirebaseAuth.User? {
        do {
            let result = try await Auth.auth().signIn(withEmail: "craigfederighi@gmail.com", password: "dynomite")
            return result.user
        } catch {
            return nil
        }
    }

    /// This can only be called during a test where the user Tim is created. Tim does not exist in FirebaseEmulatorData by default.
    @discardableResult func logInToTimAccount() async throws -> FirebaseAuth.User? {
        do {
            let result = try await Auth.auth().signIn(withEmail: "timcook@gmail.com", password: "dynomite")
            return result.user
        } catch {
            return nil
        }
    }

    @discardableResult func logInToExampleAccountForIntegrationTesting() async throws -> FirebaseAuth.User? {
        do {
            let result = try await Auth.auth().signIn(withEmail: "exampleuser@gmail.com", password: "dynomite")
            return result.user
        } catch {
            return nil
        }
    }

    func getLoggedInUserFromFirebaseAuth() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }

    func logOut() throws {
        try Auth.auth().signOut()
    }

    func userIsLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }

    func deleteAccountInFirebaseAuthAndFirestore(forUserWithUid uid: String) async throws {
        try await deleteUserFromFirestore(withUid: uid)
        try await Auth.auth().currentUser?.delete()
    }

    func signInToAccount(emailAddress: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: emailAddress, password: password)
    }
}
