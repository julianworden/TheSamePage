//
//  TestingDatabaseService.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/17/22.
//

import MapKit
import FirebaseAuth
import FirebaseFirestore
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
        try await db
            .collection(FbConstants.users)
            .document(uid)
            .delete()
    }

    // MARK: - Firestore Shows

    func getShow(with id: String) async throws -> Show {
        do {
            return try await db
                .collection(FbConstants.shows)
                .document(id)
                .getDocument(as: Show.self)
        }
    }

    func createShow(_ show: Show) throws -> String {
        return try db
            .collection(FbConstants.shows)
            .addDocument(from: show)
            .documentID
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
    func deleteShow(with id: String) async throws {
        do {
            try await db
                .collection(FbConstants.shows)
                .document(id)
                .delete()
        } catch {
            throw TestingDatabaseServiceError.firestore(message: "Failed to delete show in DatabaseService.deleteShowObject(showId:) Error \(error.localizedDescription)")
        }
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

    func createBand(_ band: Band) throws -> String {
        return try db
            .collection(FbConstants.bands)
            .addDocument(from: band)
            .documentID
    }

    func createBandWithProfileImage(_ band: Band) async throws -> String {
        let profileImageUrl = try await uploadImage(UIImage(systemName: "plus")!)
        var bandCopy = band
        bandCopy.profileImageUrl = profileImageUrl

        let docRef = try db
            .collection(FbConstants.bands)
            .addDocument(from: bandCopy)

        return docRef.documentID
    }

    func getBand(with id: String) async throws -> Band {
        return try await db
            .collection(FbConstants.bands)
            .document(id)
            .getDocument(as: Band.self)
    }

    func deleteBand(with id: String) async throws {
        do {
            try await db
                .collection(FbConstants.bands)
                .document(id)
                .delete()
        } catch {
            throw TestingDatabaseServiceError.firestore(message: "Failed to delete show in DatabaseService.deleteShowObject(showId:) Error \(error.localizedDescription)")
        }
    }

    // MARK: - Firestore BandMembers

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

    // MARK: - Firestore BandInvites

    func getBandInvite(get bandInvite: BandInvite, for user: User) async throws -> BandInvite {
        return try await db
            .collection(FbConstants.users)
            .document(user.id)
            .collection(FbConstants.notifications)
            .document(bandInvite.id)
            .getDocument(as: BandInvite.self)
    }

    // MARK: - Firestore Chats and ChatMessages

    func getChat(forShowWithId showId: String) async throws -> Chat {
        return try await db
            .collection(FbConstants.chats)
            .whereField(FbConstants.showId, isEqualTo: showId)
            .getDocuments()
            .documents
            .first!
            .data(as: Chat.self)
    }

    func deleteChat(withId id: String) async throws {
        try await db
            .collection(FbConstants.chats)
            .document(id)
            .delete()
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

    func getTotalChatCountInFirestore() async throws -> Int {
        return try await db
            .collection(FbConstants.chats)
            .count
            .getAggregation(source: .server)
            .count as! Int
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
}
