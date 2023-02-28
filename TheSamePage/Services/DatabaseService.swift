//
//  DatabaseService.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFunctions
import FirebaseStorage
import Foundation
import UIKit.UIImage
import SwiftUI

class DatabaseService: NSObject {
    
    static let shared = DatabaseService()
    
    let db = Firestore.firestore()
    
    
    // MARK: - Users
    
    
    /// Creates a user object in the Firestore users collection.
    /// - Parameters:
    ///   - user: The user being created in Firestore.
    func createUserObject(user: User) async throws {
        do {
            try db
                .collection(FbConstants.users)
                .document(user.id)
                .setData(from: user)
        } catch {
            throw FirebaseError.connection(
                message: "There was an error creating your account",
                systemError: error.localizedDescription
            )
        }
    }

    func createOrUpdateUsername(_ username: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw LogicError.unexpectedNilValue(message: "Failed to verify user's authorization status. Please try again.")
        }

        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        try await changeRequest?.commitChanges()
        try await db
            .collection(FbConstants.users)
            .document(currentUser.uid)
            .updateData([FbConstants.name: username])
    }
    
    func newUsernameIsNotAlreadyTaken(_ username: String) async throws -> Bool {
        do {
            return try await db
                .collection(FbConstants.users)
                .whereField(FbConstants.name, isEqualTo: username)
                .getDocuments()
                .documents
                .isEmpty
        } catch {
            throw FirebaseError.connection(
                message: "Failed to determine if username is unique",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Fetches the logged in user's data from Firestore.
    /// - Returns: The logged in user.
    func getLoggedInUser() async throws -> User {
        do {
            return try await db
                .collection(FbConstants.users)
                .document(AuthController.getLoggedInUid())
                .getDocument()
                .data(as: User.self)
          // Should only happen if user's account was deleted since the last time they opened the app
        } catch Swift.DecodingError.valueNotFound {
            throw FirebaseError.userNotFound(
                message: "Failed to fetch your account information. Please log in again"
            )
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch user",
                systemError: error.localizedDescription
            )
        }
    }

    func getUser(withUid uid: String) async throws -> User {
        return try await db
            .collection(FbConstants.users)
            .document(uid)
            .getDocument(as: User.self)
    }

    func getFcmToken(forUserWithUid uid: String) async throws -> String? {
        do {
            let user = try await db
                .collection(FbConstants.users)
                .document(uid)
                .getDocument(as: User.self)

            return user.fcmToken
        }
    }
    
    /// Fetches all the shows of which the signed in user is the host.
    /// - Returns: An array of shows that the signed in user is hosting.
    func getLoggedInUserHostedShows() async throws -> [Show] {
        do {
            let query = try await db
                .collection(FbConstants.shows)
                .whereField(FbConstants.hostUid, isEqualTo: AuthController.getLoggedInUid())
                .getDocuments()
            
            return try query.documents.map { try $0.data(as: Show.self) }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch your hosted shows",
                systemError: error.localizedDescription
            )
        }
    }

    func getLoggedInUserUpcomingHostedShows() async throws -> [Show] {
        do {
            let query = try await db
                .collection(FbConstants.shows)
                .whereField(FbConstants.hostUid, isEqualTo: AuthController.getLoggedInUid())
                .getDocuments()
            let hostedShows = try query.documents.map { try $0.data(as: Show.self) }

            return hostedShows.filter {
                $0.alreadyHappened == true
            }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch your hosted shows",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Fetches all the shows in which the signed in user is a participant.
    /// - Returns: All of the shows in which the signed in user is a participant.
    func getPlayingShows() async throws -> [Show] {
        do {
            let query = try await db
                .collection(FbConstants.shows)
                .whereField("participantUids", arrayContains: AuthController.getLoggedInUid())
                .getDocuments()
            
            return try query.documents.map { try $0.data(as: Show.self) }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch your shows",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Fetches the logged in user's BandInvites from their bandInvites collection.
    /// - Returns: The logged in user's BandInvites.
    func getNotifications() async throws -> [AnyUserNotification] {
        do {
            var anyUserNotifications = [AnyUserNotification]()
            
            let query = try await db
                .collection(FbConstants.users)
                .document(AuthController.getLoggedInUid())
                .collection(FbConstants.notifications)
                .getDocuments()
            
            for document in query.documents {
                if let bandInvite = try? document.data(as: BandInvite.self) {
                    let anyUserNotification = AnyUserNotification(id: bandInvite.id, notification: bandInvite)
                    anyUserNotifications.append(anyUserNotification)
                } else if let showInvite = try? document.data(as: ShowInvite.self) {
                    let anyUserNotification = AnyUserNotification(id: showInvite.id, notification: showInvite)
                    anyUserNotifications.append(anyUserNotification)
                }
            }
            
            return anyUserNotifications
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch your notification",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Updates the profileImageUrl associated with a user, uploads the new image to Firebase Storage,
    /// and deletes the old image from Firebase Storage, if it existed.
    /// - Parameters:
    ///   - image: The new image to be uploaded to Firebase Storage.
    ///   - user: The user that will be having its profileImageUrl property updated.
    /// - Returns: The download URL for the user's new profile image.
    func updateUserProfileImage(image: UIImage, user: User) async throws -> String? {
        do {
            if let oldImageUrl = user.profileImageUrl {
                let oldImageRef = Storage.storage().reference(forURL: oldImageUrl)
                try await oldImageRef.delete()
            }
            
            if let newImageUrl = try await uploadImage(image: image) {
                try await db.collection(FbConstants.users)
                    .document(user.id)
                    .updateData(["profileImageUrl": newImageUrl])
                return newImageUrl
            }

            return nil
        } catch {
            throw FirebaseError.connection(
                message: "Failed to update your profile image",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Removes a user from a band's memberUids property.
    /// - Parameters:
    ///   - user: The user that is being removed from the band.
    ///   - band: The band whose memberUids property is being altered.
    func removeUserFromBand(remove user: User, as bandMember: BandMember, from band: Band) async throws {
        do {
            try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .updateData(
                    [
                        FbConstants.memberUids: FieldValue.arrayRemove([user.id]),
                        FbConstants.memberFcmTokens: (user.fcmToken != nil ? FieldValue.arrayRemove([user.fcmToken!]): FieldValue.arrayRemove([]))
                    ]
                )
            
            try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.members)
                .document(bandMember.id)
                .delete()
            
            let bandShows = try await getShowsForBand(band: band)
            
            if !bandShows.isEmpty {
                for show in bandShows {
                    try await removeUserFromShow(uid: user.id, show: show)
                    
                    if let showChat = try await getChat(withShowId: show.id) {
                        try await removeUserFromChat(user: user, chat: showChat)
                    }
                }
            }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to remove you from \(band.name)",
                systemError: error.localizedDescription
            )
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
    
    func removeUserFromChat(user: User, chat: Chat) async throws {
        do {
            try await db
                .collection(FbConstants.chats)
                .document(chat.id)
                .updateData(
                    [
                        FbConstants.participantUids: FieldValue.arrayRemove([user.id]),
                        FbConstants.participantUsernames: FieldValue.arrayRemove([user.name])
                    ]
                )
        } catch {
            throw FirebaseError.connection(
                message: "Failed to remove you from \(chat.name ?? "chat")",
                systemError: error.localizedDescription
            )
        }
    }
    
    func removeUserFromShow(uid: String, show: Show) async throws {
        do {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([FbConstants.participantUids: FieldValue.arrayRemove([uid])])
        } catch {
            throw FirebaseError.connection(
                message: "Failed to remove you from \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Fetches all the bands in the bands collection that include a given UID in their memberUids array.
    /// - Parameter uid: The UID for which the search is occuring in the bands' memberUids array.
    /// - Returns: The bands that include the provided UID in the memberUids array.
    func getJoinedBands(withUid uid: String) async throws -> [Band] {
        do {
            let query = try await db
                .collection(FbConstants.bands)
                .whereField(FbConstants.memberUids, arrayContains: uid)
                .getDocuments()
            
            return try query.documents.map { try $0.data(as: Band.self) }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch your bands",
                systemError: error.localizedDescription
            )
        }
    }

    /// Fetches all the bands in the bands collection that have an adminUid property that matches a given UID.
    /// - Parameter uid: The UID that must match a band's adminUid property in order for that band to be returned.
    /// - Returns: The bands with an adminUid property that matches the UID in the uid property.
    func getAdminBands(withUid uid: String) async throws -> [Band] {
        do {
            let query = try await db
                .collection(FbConstants.bands)
                .whereField(FbConstants.adminUid, isEqualTo: uid)
                .getDocuments()

            return try query.documents.map { try $0.data(as: Band.self) }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch your bands",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Queries Firestore to convert a BandMember object to a User object. Used to open a user's profile when they've
    /// been selected on a band's member list.
    /// - Parameter bandMember: The BandMember object that will be converted into a User object.
    /// - Returns: The user returned from Firestore that corresponds to the BandMember object passed into the bandMember parameter.
    func convertBandMemberToUser(bandMember: BandMember) async throws -> User {
        do {
            return try await db
                .collection(FbConstants.users)
                .document(bandMember.uid)
                .getDocument(as: User.self)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch user profile",
                systemError: error.localizedDescription
            )
        }
    }

    /// Queries Firestore to convert a BandMember object to a User object. Used to open a user's profile when they've
    /// been selected on a band's member list.
    /// - Parameter bandMember: The BandMember object that will be converted into a User object.
    /// - Returns: The user returned from Firestore that corresponds to the BandMember object passed into the bandMember parameter.
    func convertUserToBandMember(user: User, band: Band) async throws -> BandMember {
        do {
            let userAsBandMemberDocuments = try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.members)
                .whereField(FbConstants.uid, isEqualTo: user.id)
                .getDocuments()
                .documents

            guard !userAsBandMemberDocuments.isEmpty && userAsBandMemberDocuments.count == 1 else {
                throw LogicError.unexpectedNilValue(message: "Failed to fetch band member information. Please restart The Same Page and try again.")
            }

            return try userAsBandMemberDocuments.first!.data(as: BandMember.self)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch user profile",
                systemError: error.localizedDescription
            )
        }
    }

    /// Deletes a user's profile image in Firebase Storage, and deletes the value in their profileImageUrl property.
    /// - Parameter user: The user who will have their profile image deleted.
    func deleteUserProfileImage(forUser user: User) async throws {
        guard let profileImageUrl = user.profileImageUrl else {
            throw LogicError.unexpectedNilValue(message: "Profile image delete failed, you don't have a profile image")
        }

        do {
            try await deleteImage(at: profileImageUrl)

            try await db
                .collection(FbConstants.users)
                .document(user.id)
                .updateData([FbConstants.profileImageUrl: FieldValue.delete()])
        } catch {
            throw FirebaseError.connection(message: "Failed to delete image", systemError: error.localizedDescription)
        }
    }

    func deleteUserFromFirestore(withUid uid: String) async throws {
        let loggedInUser = try await getLoggedInUser()

        try await FirebaseFunctionsController.recursiveDelete(path: "\(FbConstants.users)/\(uid)")

        let userShows = try await getPlayingShows()
        for show in userShows {
            try await removeUserFromShow(uid: uid, show: show)
        }

        let userChats = try await getChats(forUserWithUid: uid)
        for chat in userChats {
            try await removeUserFromChat(user: loggedInUser, chat: chat)
        }

        let userBands = try await getJoinedBands(withUid: uid)
        for band in userBands {
            try await removeUserFromBand(uid: uid, bandId: band.id)
        }
    }

    func deleteAccountInFirebaseAuthAndFirestore(forUserWithUid uid: String) async throws {
        do {
            try await deleteUserFromFirestore(withUid: uid)
            try await Auth.auth().currentUser?.delete()
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete account. Please try again",
                systemError: error.localizedDescription
            )
        }
    }

    func changeEmailAddress(to emailAddress: String) async throws {
        try await Auth.auth().currentUser?.updateEmail(to: emailAddress)

        do {
            try await db
                .collection(FbConstants.users)
                .document(AuthController.getLoggedInUid())
                .updateData([FbConstants.emailAddress: emailAddress])
        } catch {
            throw FirebaseError.connection(message: "Email address update failed", systemError: error.localizedDescription)
        }
    }

    
    
    // MARK: - Bands
    
    
    func getBand(with id: String) async throws -> Band {
        do {
            return try await db
                .collection(FbConstants.bands)
                .document(id)
                .getDocument(as: Band.self)
        } catch DecodingError.valueNotFound {
            throw FirebaseError.dataDeleted
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch band",
                systemError: error.localizedDescription
            )
        }
    }

    func getAllBands(withUid uid: String) async throws -> [Band] {
        do {
            var allBands = [Band]()

            let memberBandsAsDocuments = try await db
                .collection(FbConstants.bands)
                .whereField(FbConstants.memberUids, arrayContains: uid)
                .getDocuments()
                .documents

            let adminBandsAsDocuments = try await db
                .collection(FbConstants.bands)
                .whereField(FbConstants.adminUid, isEqualTo: uid)
                .getDocuments()
                .documents

            for bandDocument in memberBandsAsDocuments {
                if let band = try? bandDocument.data(as: Band.self) {
                    allBands.append(band)
                }
            }

            for bandDocument in adminBandsAsDocuments {
                if let band = try? bandDocument.data(as: Band.self),
                   !allBands.contains(band) {
                    allBands.append(band)
                }
            }

            return allBands
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch user band info",
                systemError: error.localizedDescription
            )
        }
    }

    /// Fetches user objects for all of the users listed in the memberUids property of a band.
    /// - Parameter band: The band whose members are being fetched.
    /// - Returns: The users that are playing in the band. Even if the admin of the band
    /// is also a band member, this array will not include the band admin.
    func getUsersPlayingInBand(band: Band) async throws -> [User] {
        do {
            var usersPlayingInBand = [User]()

            for uid in band.memberUids {
                if uid != band.adminUid {
                    let fetchedUser = try await getUser(withUid: uid)
                    usersPlayingInBand.append(fetchedUser)
                }
            }

            return usersPlayingInBand
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch the users that are playing in this band",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Fetches all of the shows that a band is playing.
    /// - Parameter band: The band for which the show search is taking place.
    /// - Returns: The shows that the given band is playing.
    func getShowsForBand(band: Band) async throws -> [Show] {
        do {
            let showsQuery = try await db
                .collection(FbConstants.shows)
                .whereField("bandIds", arrayContains: band.id)
                .getDocuments()
            
            let fetchedShows = try showsQuery.documents.map { try $0.data(as: Show.self) }
            return fetchedShows
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch band's shows",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Fetches the BandMember objects in a specified band's members collection.
    /// - Parameter band: The band for which the search is occuring.
    /// - Returns: An array of the BandMember objects associated with the band passed into the band parameter.
    func getBandMembers(forBand band: Band) async throws -> [BandMember] {
        do {
            let query = try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.members)
                .getDocuments()
            
            return try query.documents.map { try $0.data(as: BandMember.self) }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch band members",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Creates a band in the Firestore bands collection.
    /// - Parameter band: The band to be added to Firestore.
    func createBand(band: Band) async throws -> String {
        do {
            let bandReference = try db
                .collection(FbConstants.bands)
                .addDocument(from: band)
            
            try await bandReference.updateData(["id": bandReference.documentID])
            return bandReference.documentID
        } catch {
            throw FirebaseError.connection(
                message: "Failed to create band",
                systemError: error.localizedDescription
            )
        }
    }

    /// Edits the adminUid property of a band so that a new user can become a band admin. At this time,
    /// this method only allows for other existing members of the band to become the band admin. This may
    /// change in the future.
    /// - Parameters:
    ///   - user: The user who is to become the new admin of the band.
    ///   - band: The band whose adminUid property is being edited.
    func setNewBandAdmin(user: User, band: Band) async throws {
        do {
            guard band.memberUids.contains(user.id) else {
                throw LogicError.unknown(message: "\(user.fullName) cannot be the admin of this band because they are not currently a member of the band.")
            }

            try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .updateData([FbConstants.adminUid: user.id])
        } catch {
            throw FirebaseError.connection(
                message: "Failed to designate new band admin. Please try again",
                systemError: error.localizedDescription
            )
        }
    }
    
    func updateBand(band: Band) async throws {
        do {
            try db
                .collection(FbConstants.bands)
                .document(band.id).setData(from: band, merge: true)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to update band info",
                systemError: error.localizedDescription
            )
        }
    }
    
    // TODO: Make this method check if the invited member is already a member of the band
    /// Adds a user as a BandMember to a band's members collection. This is called when a BandInvite is accepted, and when a user indicates
    /// that they are a member of the band they are creating in AddEditBandView. If a BandInvite is being accepted, this method also calls
    /// a subsequent DatabaseService method that deletes the BandInvite from the user's bandInvites collection.
    /// - Parameters:
    ///   - bandMember: The new band member.
    ///   - joinedBandId: The Document ID for the band that the new member is joining.
    ///   - bandInvite: The band invite that is being accepted.
    func addUserToBand(
        add user: User,
        as bandMember: BandMember,
        to band: Band,
        withBandInvite bandInvite: BandInvite?
    ) async throws {
        do {
            let bandMemberDocument = try db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.members)
                .addDocument(from: bandMember)
            try await bandMemberDocument.updateData([FbConstants.id: bandMemberDocument.documentID])
            
            try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .updateData(
                    [
                        FbConstants.memberUids: FieldValue.arrayUnion([bandMember.uid]),
                        FbConstants.memberFcmTokens: (user.fcmToken != nil ? FieldValue.arrayUnion([user.fcmToken!]) : FieldValue.arrayUnion([]))
                    ]
                )
            
            let bandShows = try await getShowsForBand(band: band)
            
            if !bandShows.isEmpty {
                for show in bandShows {
                    try await addUserToShow(add: user, to: show)
                }
            }
            
            if let bandInvite {
                try await deleteNotification(withId: bandInvite.id)
            }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add you to \(band.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Adds a social media link to a band's links collection.
    /// - Parameters:
    ///   - link: The link to be added to the band's links collection.
    ///   - band: The band that the link belongs to.
    func uploadBandLink(withLink link: PlatformLink, forBand band: Band) throws {
        do {
            _ = try db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection("links")
                .addDocument(from: link)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(link.platformName) link for \(band.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Updates the profileImageUrl associated with a band, uploads the new image to Firebase Storage,
    /// and deletes the old image from Firebase Storage, if it existed.
    /// - Parameters:
    ///   - image: The new image to be uploaded to Firebase Storage.
    ///   - band: The band that will be having its profileImageUrl property updated.
    func updateBandProfileImage(image: UIImage, band: Band) async throws -> String? {
        do {
            if let oldImageUrl = band.profileImageUrl {
                let oldImageRef = Storage.storage().reference(forURL: oldImageUrl)
                try await oldImageRef.delete()
            }
            
            if let newImageUrl = try await uploadImage(image: image) {
                try await db
                    .collection(FbConstants.bands)
                    .document(band.id)
                    .updateData(["profileImageUrl": newImageUrl])
                return newImageUrl
            }

            return nil
        } catch {
            throw FirebaseError.connection(
                message: "Failed to update \(band.name)'s profile image",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Sends an invitation to a user to join a band. Uploads a BandInvite object to the specified user's bandInvites collection in
    /// Firestore.
    /// - Parameter invite: The BandInvite that is being sent.
    func sendBandInvite(invite: BandInvite) async throws -> String {
        do {
            let bandInviteDocument = try db
                .collection(FbConstants.users)
                .document(invite.recipientUid)
                .collection(FbConstants.notifications)
                .addDocument(from: invite)
            try await bandInviteDocument.updateData([FbConstants.id: bandInviteDocument.documentID])
            return bandInviteDocument.documentID
        } catch {
            throw FirebaseError.connection(
                message: "Failed to send band invite",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Fetches a band's links from their links collection.
    /// - Parameter band: The band whose links are to be fetched.
    /// - Returns: An array of the links that the provided band has.
    func getBandLinks(forBand band: Band) async throws -> [PlatformLink] {
        do {
            let query = try await db
                .collection(FbConstants.bands)
                .document(band.id).collection("links")
                .getDocuments()
            
            return try query.documents.map { try $0.data(as: PlatformLink.self) }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch \(band.name)'s links",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Converts a ShowParticipant object to a Band object. Necessary for when a band is selected
    /// from a show's lineup list.
    /// - Parameter showParticipant: The ShowParticipant to be converted.
    /// - Returns: The Band object that the showParticipant was converted into.
    func convertShowParticipantToBand(showParticipant: ShowParticipant) async throws -> Band {
        do {
            return try await db
                .collection(FbConstants.bands)
                .document(showParticipant.bandId)
                .getDocument(as: Band.self)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch band profile",
                systemError: error.localizedDescription
            )
        }
    }

    /// Deletes a band's profile image in Firebase Storage, and deletes the value in their profileImageUrl property.
    /// - Parameter band: The band that will have their profile image deleted.
    func deleteBandImage(forBand band: Band) async throws {
        guard let profileImageUrl = band.profileImageUrl else {
            throw LogicError.unexpectedNilValue(message: "Image delete failed, this band doesn't have a profile image")
        }

        do {
            try await deleteImage(at: profileImageUrl)

            try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .updateData([FbConstants.profileImageUrl: FieldValue.delete()])
        } catch {
            throw FirebaseError.connection(message: "Failed to delete image", systemError: error.localizedDescription)
        }
    }

    func deleteBand(_ band: Band) async throws {
        do {
            let bandMembers = try await getBandMembers(forBand: band)
            let bandShows = try await getShowsForBand(band: band)

            for show in bandShows {
                let bandAsShowParticipant = try await convertBandToShowParticipant(band: band, show: show)

                try await removeShowParticipantFromShow(remove: bandAsShowParticipant, from: show)
            }

            try await FirebaseFunctionsController.recursiveDelete(path: "\(FbConstants.bands)/\(band.id)")
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete show chat",
                systemError: error.localizedDescription
            )
        }
    }

    func deleteBandLink(band: Band, link: PlatformLink) async throws {
        guard let platformLinkId = link.id else {
            throw LogicError.unexpectedNilValue(message: "Failed to delete band link. Please try again.")
        }
        do {
            try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.links)
                .document(platformLinkId)
                .delete()
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete band link",
                systemError: error.localizedDescription
            )
        }
    }
    
    
    // MARK: - Shows

    func getShow(showId: String) async throws -> Show {
        do {
            return try await db
                .collection(FbConstants.shows)
                .document(showId)
                .getDocument(as: Show.self)
        } catch DecodingError.valueNotFound {
            throw FirebaseError.dataDeleted
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch latest show data, it's possible this show was cancelled",
                systemError: error.localizedDescription
            )
        }
    }

    func getAllShows(withUid uid: String) async throws -> [Show] {
        do {
            var allShows = [Show]()

            let playingShowsAsDocuments = try await db
                .collection(FbConstants.shows)
                .whereField(FbConstants.participantUids, arrayContains: uid)
                .getDocuments()
                .documents

            let hostedShowsAsDocuments = try await db
                .collection(FbConstants.shows)
                .whereField(FbConstants.hostUid, isEqualTo: uid)
                .getDocuments()
                .documents

            for showDocument in playingShowsAsDocuments {
                if let show = try? showDocument.data(as: Show.self) {
                    allShows.append(show)
                }
            }

            for showDocument in hostedShowsAsDocuments {
                if let show = try? showDocument.data(as: Show.self),
                   !allShows.contains(show) {
                    allShows.append(show)
                }
            }

            return allShows
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch user show info",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Creates a show in the Firestore shows collection and also adds the show's id
    /// to the logged in user's hostedShows collection.
    ///
    /// When offline, this method will store the show in the cache and run it next time the app is online, which in testing
    /// seems to create the show, including the id property, successfully. it will not throw an error due to not being online. This is
    /// because the Firestore updateData method waits for a response from the server before running any code that comes after it.
    /// - Parameter show: The show to be added to Firestore.
    func createShow(show: Show) async throws -> String {
        do {
            let showReference = try db.collection(FbConstants.shows).addDocument(from: show)
            try await showReference.updateData(["id": showReference.documentID])
            return showReference.documentID
        } catch {
            throw FirebaseError.connection(
                message: "Show creation failed. Please check your internet connection and try again.",
                systemError: error.localizedDescription
            )
        }
    }
    
    func getShowLineup(forShow show: Show) async throws -> [ShowParticipant] {
        let query = try await db.collection(FbConstants.shows).document(show.id).collection("participants").getDocuments()
        
        do {
            return try query.documents.map { try $0.data(as: ShowParticipant.self) }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch the lineup for \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }

    /// Fetches user objects for all of the users listed in a show's participantUids property.
    /// - Parameter show: The show whose participants are being fetched.
    /// - Returns: The users that are playing the show. Even if the host of the show
    /// is also in the participantUids array, this array will not include the band admin.
    func getUsersPlayingShow(show: Show) async throws -> [User] {
        do {
            var usersPlayingShow = [User]()

            for uid in show.participantUids {
                if uid != show.hostUid {
                    let fetchedUser = try await getUser(withUid: uid)
                    usersPlayingShow.append(fetchedUser)
                }
            }

            return usersPlayingShow
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch the users that are playing this show",
                systemError: error.localizedDescription
            )
        }
    }
    
    func updateShow(show: Show) async throws {
        do {
            try db
                .collection(FbConstants.shows)
                .document(show.id)
                .setData(from: show, merge: true)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to update \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }

    /// Called when a show host designates a new user as the host for their show. This replaces the existing value of the hostUid property
    /// with a new UID belonging to the new show host. At this time, this method only allows for an existing show participant
    /// to become the new show host. This may change in the future.
    /// - Parameters:
    ///   - user: The new show host.
    ///   - show: The show that the new show host will be hosting.
    func setNewShowHost(user: User, show: Show) async throws {
        do {
            guard show.participantUids.contains(user.id) else {
                throw LogicError.unknown(message: "\(user.fullName) cannot host this show because they are not participating in it.")
            }

            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([FbConstants.hostUid: user.id])
        } catch {
            throw FirebaseError.connection(
                message: "Failed to designate new show host. Please try again",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Updates the imageUrl associated with a show, uploads the new image to Firebase Storage,
    /// and deletes the old image from Firebase Storage, if it existed.
    /// - Parameters:
    ///   - image: The new image to be uploaded to Firebase Storage.
    ///   - show: The show that will be having its imageUrl property updated.
    func updateShowImage(image: UIImage, show: Show) async throws -> String? {
        do {
            // Delete old image if it exists
            if let oldImageUrl = show.imageUrl {
                let oldImageRef = Storage.storage().reference(forURL: oldImageUrl)
                try await oldImageRef.delete()
            }
            
            if let newImageUrl = try await uploadImage(image: image) {
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(["imageUrl": newImageUrl])
                return newImageUrl
            }

            return nil
        } catch {
            throw FirebaseError.connection(
                message: "Failed to update image for \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Sends an invitation to a band's admin to have their band join a show. Uploads a ShowInvite object
    /// to the specified user's showInvites collection in Firestore.
    /// - Parameter invite: The ShowInvite that is being sent.
    func sendShowInvite(invite: ShowInvite) async throws -> String {
        do {
            let showInviteDocument = try db
                .collection(FbConstants.users)
                .document(invite.recipientUid)
                .collection(FbConstants.notifications)
                .addDocument(from: invite)
            try await showInviteDocument.updateData([FbConstants.id: showInviteDocument.documentID])
            return showInviteDocument.documentID
        } catch {
            throw FirebaseError.connection(
                message: "Failed to send show invite to \(invite.bandName)",
                systemError: error.localizedDescription
            )
        }
    }

    func sendShowApplication(application: ShowApplication) async throws -> String {
        do {
            let showApplicationDocument = try db
                .collection(FbConstants.users)
                .document(application.recipientUid)
                .collection(FbConstants.notifications)
                .addDocument(from: application)
            try await showApplicationDocument.updateData([FbConstants.id: showApplicationDocument.documentID])
            return showApplicationDocument.documentID
        } catch {
            throw FirebaseError.connection(
                message: "Failed to send show application",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Adds band to show's bands collection, adds band members to show's chat, and adds user to show's participants collection.
    /// Also deletes the ShowInvite in the user's showInvites collection.
    ///
    /// This method should only be used when a band is being added to a show via a ShowInvite. Otherwise, use
    /// addBandToShow(add:as:to:)
    /// - Parameter showParticipant: The showParticipant to be added to the Show's participants collection.
    /// - Parameter showInvite: The ShowInvite that was accepted in order for the band to get added to the show.
    /// - Parameter band: The band to be added to the show.
    func addBandToShow(add band: Band, as showParticipant: ShowParticipant, withShowInvite showInvite: ShowInvite) async throws {
        do {
            // Add showParticipant to the show's participants collection
            _ = try db
                .collection(FbConstants.shows)
                .document(showInvite.showId)
                .collection(FbConstants.participants)
                .addDocument(from: showParticipant)
            
            // Add the band's ID to the show's bandIds property
            try await db
                .collection(FbConstants.shows)
                .document(showInvite.showId)
                .updateData([FbConstants.bandIds: FieldValue.arrayUnion([band.id])])
            
            if !band.memberUids.isEmpty {
                try await db
                    .collection(FbConstants.shows)
                    .document(showInvite.showId)
                    .updateData(
                        [
                            FbConstants.participantUids: FieldValue.arrayUnion(band.memberUids)
                        ]
                    )
                try await addBandToChat(band: band, showId: showInvite.showId)
            }
            
            // Check to see if the band admin is already in the memberUids array. If it isn't, add it to the show's participantUids property.
            if !band.memberUids.contains(band.adminUid) {
                let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
                try await db
                    .collection(FbConstants.shows)
                    .document(showInvite.showId)
                    .updateData([FbConstants.participantUids: FieldValue.arrayUnion([band.adminUid])])
                try await addUserToChat(user: loggedInUser, showId: showInvite.showId)
            }
            
            
            try await deleteNotification(withId: showInvite.id)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(band.name) to \(showInvite.showName)",
                systemError: error.localizedDescription
            )
        }
    }

    func addBandToShow(add band: Band, as showParticipant: ShowParticipant, withShowApplication showApplication: ShowApplication) async throws {
        do {
            // Add showParticipant to the show's participants collection
            _ = try db
                .collection(FbConstants.shows)
                .document(showApplication.showId)
                .collection(FbConstants.participants)
                .addDocument(from: showParticipant)

            // Add the band's ID to the show's bandIds property
            try await db
                .collection(FbConstants.shows)
                .document(showApplication.showId)
                .updateData([FbConstants.bandIds: FieldValue.arrayUnion([band.id])])

            if !band.memberUids.isEmpty {
                try await db
                    .collection(FbConstants.shows)
                    .document(showApplication.showId)
                    .updateData(
                        [
                            FbConstants.participantUids: FieldValue.arrayUnion(band.memberUids)
                        ]
                    )
                try await addBandToChat(band: band, showId: showApplication.showId)
            }

            // Check to see if the band admin is already in the memberUids array. If it isn't, add it to the show's participantUids property.
            if !band.memberUids.contains(band.adminUid) {
                let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
                try await db
                    .collection(FbConstants.shows)
                    .document(showApplication.showId)
                    .updateData([FbConstants.participantUids: FieldValue.arrayUnion([band.adminUid])])
                try await addUserToChat(user: loggedInUser, showId: showApplication.showId)
            }


            try await deleteNotification(withId: showApplication.id)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(band.name) to \(showApplication.showName)",
                systemError: error.localizedDescription
            )
        }
    }

    /// Adds band to show's bands collection, adds band members to show's chat, and adds user to show's participants
    /// collection.
    /// - Parameters:
    ///   - band: The band to be added to the show.
    ///   - showParticipant: The showParticipant to be added to the Show's participants collection.
    ///   - show: The show that the given band will be joining.
    func addBandToShow(add band: Band, as showParticipant: ShowParticipant, to show: Show) async throws {
        do {
            // Add showParticipant to the show's participants collection
            _ = try db
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
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(band.name) to \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }

    /// Removes a band from a show. This method removes the band's id from the show's bandIds property, removes
    /// each of the band's member's UIDs from the show's participantUids property, and removes each of the band's
    /// member's from the show's chat.
    /// - Parameters:
    ///   - showParticipant: The show participant that is to be removed from the show.
    ///   - show: The show from which the band in the band property will be removed.
    func removeShowParticipantFromShow(remove showParticipant: ShowParticipant, from show: Show) async throws {
        guard let showParticipantId = showParticipant.id else {
            throw LogicError.unexpectedNilValue(message: "Failed to remove band from show, please try again.")
        }

        let showParticipantAsBand = try await getBand(with: showParticipant.bandId)

        try await db
            .collection(FbConstants.shows)
            .document(show.id)
            .updateData([FbConstants.bandIds: FieldValue.arrayRemove([showParticipant.bandId])])

        try await db
            .collection(FbConstants.shows)
            .document(show.id)
            .collection(FbConstants.participants)
            .document(showParticipantId)
            .delete()

        try await db
            .collection(FbConstants.shows)
            .document(show.id)
            .updateData([FbConstants.participantUids: FieldValue.arrayRemove(showParticipantAsBand.memberUids)])

        for uid in showParticipantAsBand.memberUids {
            if uid != show.hostUid {
                try await deleteBackline(fromUserWithUid: uid, in: show)
            }
        }

        if !showParticipantAsBand.memberUids.contains(showParticipantAsBand.adminUid) {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([FbConstants.participantUids: FieldValue.arrayRemove([showParticipantAsBand.adminUid])])

            if showParticipantAsBand.adminUid != show.hostUid {
                try await deleteBackline(fromUserWithUid: showParticipantAsBand.adminUid, in: show)
            }
        }

        if let showChat = try await getChat(withShowId: show.id) {
            for uid in showParticipantAsBand.memberUids {
                let bandMemberAsUser = try await getUser(withUid: uid)
                try await removeUserFromChat(user: bandMemberAsUser, chat: showChat)
            }

            if !showParticipantAsBand.memberUids.contains(showParticipantAsBand.adminUid) {
                let bandAdminAsUser = try await getUser(withUid: showParticipantAsBand.adminUid)
                try await removeUserFromChat(user: bandAdminAsUser, chat: showChat)
            }
        }
    }
    
    func addUserToShow(add user: User, to show: Show) async throws {
        do {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([FbConstants.participantUids: FieldValue.arrayUnion([user.id])])
            
            if let showChat = try await getChat(withShowId: show.id) {
                try await db
                    .collection(FbConstants.chats)
                    .document(showChat.id)
                    .updateData([FbConstants.participantUids: FieldValue.arrayUnion([user.id])])
            }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(user.name) to \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    func addTimeToShow(addTime time: Date, ofType showTimeType: ShowTimeType, forShow show: Show) async throws {
        do {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([showTimeType.fbFieldValueName: time.timeIntervalSince1970])
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(showTimeType.rawValue) time to \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    func deleteTimeFromShow(delete showTimeType: ShowTimeType, fromShow show: Show) async throws {
        do {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([showTimeType.fbFieldValueName: FieldValue.delete()])
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete \(showTimeType.rawValue) time from \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    func addBacklineItemToShow(backlineItem: BacklineItem?, drumKitBacklineItem: DrumKitBacklineItem?, show: Show) throws -> String {
        do {
            if let backlineItem {
                let backlineItemDocument = try db.collection(FbConstants.shows)
                    .document(show.id)
                    .collection("backlineItems")
                    .addDocument(from: backlineItem)
                return backlineItemDocument.documentID
            }
            
            if let drumKitBacklineItem {
                let drumKitBacklineItem = try db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .collection("backlineItems")
                    .addDocument(from: drumKitBacklineItem)
                return drumKitBacklineItem.documentID
            }

            throw LogicError.unexpectedNilValue(message: "Invalid Backline item assignment")
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add backline item to \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    func getBacklineItems(forShow show: Show) async throws -> [AnyBackline] {
        do {
            let fetchedBacklineItemDocuments = try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection(FbConstants.backlineItems)
                .getDocuments()
                .documents

            var backlineItemsAsAnyBackline = [AnyBackline]()

            for document in fetchedBacklineItemDocuments {
                if let drumKitBacklineItem = try? document.data(as: DrumKitBacklineItem.self) {
                    backlineItemsAsAnyBackline.append(AnyBackline(id: drumKitBacklineItem.id!, backline: drumKitBacklineItem))
                } else if let backlineItem = try? document.data(as: BacklineItem.self) {
                    backlineItemsAsAnyBackline.append(AnyBackline(id: backlineItem.id!, backline: backlineItem))
                }
            }

            return backlineItemsAsAnyBackline
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch backline items for \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    func getDrumKitBacklineItems(forShow show: Show) async throws -> [DrumKitBacklineItem] {
        do {
            let query = try await db.collection(FbConstants.shows)
                .document(show.id)
                .collection("backlineItems")
                .getDocuments()
            
            return try query.documents.map { try $0.data(as: DrumKitBacklineItem.self) }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch drumkit backline items for \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }

    func deleteBacklineItem(delete backline: any Backline, inShowWithId showId: String) async throws {
        guard let backlineItemId = backline.id else {
            throw LogicError.unexpectedNilValue(message: "Failed to delete backline item, please try again.")
        }

        do {
            try await db
                .collection(FbConstants.shows)
                .document(showId)
                .collection(FbConstants.backlineItems)
                .document(backlineItemId)
                .delete()
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete backline item",
                systemError: error.localizedDescription
            )
        }
    }

    func deleteDrumKitBacklineItem(delete drumKitBacklineItem: DrumKitBacklineItem, inShowWithId showId: String) async throws {
        guard let drumKitBacklineItemId = drumKitBacklineItem.id else {
            throw LogicError.unexpectedNilValue(message: "Failed to delete backline item, please try again.")
        }

        do {
            try await db
                .collection(FbConstants.shows)
                .document(showId)
                .collection(FbConstants.backlineItems)
                .document(drumKitBacklineItemId)
                .delete()
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete backline item",
                systemError: error.localizedDescription
            )
        }
    }

    func deleteBackline(fromUserWithUid uid: String, in show: Show) async throws {
        do {
            let backlineAsDocuments = try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection(FbConstants.backlineItems)
                .whereField(FbConstants.backlinerUid, isEqualTo: uid)
                .getDocuments()
                .documents

            for backlineDocument in backlineAsDocuments {
                if let backlineItem = try? backlineDocument.data(as: BacklineItem.self) {
                    try await deleteBacklineItem(delete: backlineItem, inShowWithId: show.id)
                } else if let drumKitBacklineItem = try? backlineDocument.data(as: DrumKitBacklineItem.self) {
                    try await deleteBacklineItem(delete: drumKitBacklineItem, inShowWithId: show.id)
                }
            }
        } catch DecodingError.valueNotFound, DecodingError.keyNotFound {
            return
        } catch {
            throw FirebaseError.connection(message: "Failed to delete backline from show participant.", systemError: error.localizedDescription)
        }
    }

    func deleteNotification(withId id: String) async throws {
        do {
            try await db
                .collection(FbConstants.users)
                .document(AuthController.getLoggedInUid())
                .collection(FbConstants.notifications)
                .document(id)
                .delete()

        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete notification",
                systemError: error.localizedDescription
            )
        }
    }
    
    func cancelShow(show: Show) async throws {
        do {
            try await FirebaseFunctionsController.recursiveDelete(path: "\(FbConstants.shows)/\(show.id)")
            try await deleteChat(for: show)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to cancel \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }

    /// Deletes a show's profile image in Firebase Storage, and deletes the value in their imageUrl property.
    /// - Parameter show: The show that will have their profile image deleted.
    func deleteShowImage(forShow show: Show) async throws {
        guard let showImageUrl = show.imageUrl else {
            throw LogicError.unexpectedNilValue(message: "Image delete failed, this show doesn't have an image")
        }

        do {
            try await deleteImage(at: showImageUrl)

            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([FbConstants.imageUrl: FieldValue.delete()])
        } catch {
            throw FirebaseError.connection(message: "Failed to delete image", systemError: error.localizedDescription)
        }
    }

    func addEditSetTime(newSetTime: Date, for showParticipant: ShowParticipant, in show: Show) async throws {
        guard let showParticipantId = showParticipant.id else {
            throw LogicError.unexpectedNilValue(message: "Failed to edit set time, please restart The Same Page and try again")
        }

        do {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection(FbConstants.participants)
                .document(showParticipantId)
                .updateData([FbConstants.setTime: newSetTime.timeIntervalSince1970])
        } catch {
            throw FirebaseError.connection(message: "Failed to edit set time", systemError: error.localizedDescription)
        }
    }

    func deleteSetTime(for showParticipant: ShowParticipant, in show: Show) async throws {
        guard let showParticipantId = showParticipant.id else {
            throw LogicError.unexpectedNilValue(message: "Failed to delete set time, please restart The Same Page and try again")
        }

        do {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection(FbConstants.participants)
                .document(showParticipantId)
                .updateData([FbConstants.setTime: FieldValue.delete()])
        } catch {
            throw FirebaseError.connection(message: "Failed to delete set time", systemError: error.localizedDescription)
        }
    }

    func convertBandToShowParticipant(band: Band, show: Show) async throws -> ShowParticipant {
        do {
            let showParticipantAsDocumentArray = try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection(FbConstants.participants)
                .whereField(FbConstants.bandId, isEqualTo: band.id)
                .getDocuments()
                .documents

            guard showParticipantAsDocumentArray.count == 1,
                  let showParticipantAsDocument = showParticipantAsDocumentArray.first else {
                throw FirebaseError.dataNotFound
            }

            return try showParticipantAsDocument.data(as: ShowParticipant.self)
        } catch {
            throw FirebaseError.connection(message: "Failed to perform band operation", systemError: error.localizedDescription)
        }
    }


    
    // MARK: - Chats



    /// Fetches the chat that belongs to a given show.
    /// - Parameter showId: The ID of the show that the fetched chat is associated with.
    /// - Returns: The fetched chat associated with the show passed into the showId property. Returns nil if no chat is found for a show.
    /// It is up to the caller to determine what actions to take when nil is returned.
    func getChat(withShowId showId: String) async throws -> Chat? {
        do {
            let chat = try await db
                .collection(FbConstants.chats)
                .whereField(FbConstants.showId, isEqualTo: showId)
                .getDocuments()
            
            // Each show should only have 1 chat
            guard !chat.documents.isEmpty && chat.documents[0].exists && chat.documents.count == 1 else { return nil }
            
            let fetchedChat = try chat.documents[0].data(as: Chat.self)
            return fetchedChat
        } catch Swift.DecodingError.keyNotFound {
            throw FirebaseError.dataNotFound
        } catch {
            throw FirebaseError.connection(
                message: "Failed to get fetch show chat",
                systemError: error.localizedDescription
            )
        }
    }

    func getChats(forUserWithUid uid: String) async throws -> [Chat] {
        let chatDocuments = try await db
            .collection(FbConstants.chats)
            .whereField(FbConstants.participantUids, arrayContains: uid)
            .getDocuments()
            .documents

        return try chatDocuments.map { try $0.data(as: Chat.self) }
    }

    func getChat(withId id: String) async throws -> Chat {
        do {
            return try await db
                .collection(FbConstants.chats)
                .document(id)
                .getDocument(as: Chat.self)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch chat",
                systemError: error.localizedDescription
            )
        }
    }

    func getChat(ofType chatType: ChatType, withParticipantUids participantUids: [String]) async throws -> Chat? {
        do {
            guard !participantUids.isEmpty,
                  let chatParticipantUid = participantUids.first else {
                throw LogicError.unexpectedNilValue(message: "Something went wrong. Please restart The Same Page, ensure you have an internet connection, and try again.")
            }

            let possibleChatMatchesAsDocuments = try await db
                .collection(FbConstants.chats)
                .whereField(FbConstants.participantUids, arrayContains: chatParticipantUid)
                .getDocuments()
                .documents
            
            let possibleChatMatches = try possibleChatMatchesAsDocuments.map { try $0.data(as: Chat.self) }
            let matchedChat = possibleChatMatches.filter {
                $0.participantUids.count == participantUids.count &&
                $0.type == chatType.rawValue &&
                $0.participantUids.contains(participantUids)
            }

            if matchedChat.isEmpty {
                return nil
            }

            guard matchedChat.count == 1,
                  let chatToReturn = matchedChat.first else {
                throw LogicError.unknown(message: "Something went wrong. Please restart The Same Page, ensure you have an internet connection, and try again.")
            }

            return chatToReturn
        } catch Swift.DecodingError.keyNotFound {
            throw FirebaseError.dataNotFound
        } catch {
            print(error)
            throw FirebaseError.connection(
                message: "Failed to fetch or create chat",
                systemError: error.localizedDescription
            )
        }
    }

    func addUserToCurrentChatViewers(uid: String, chatId: String) async throws {
        do {
            try await db
                .collection(FbConstants.chats)
                .document(chatId)
                .updateData([FbConstants.currentViewerUids: FieldValue.arrayUnion([uid])])
        } catch {
            throw FirebaseError.connection(message: "Failed to establish up-to-date chat info", systemError: error.localizedDescription)
        }
    }

    func removeUserFromCurrentChatViewers(uid: String, chatId: String) async throws {
        do {
            try await db
                .collection(FbConstants.chats)
                .document(chatId)
                .updateData([FbConstants.currentViewerUids: FieldValue.arrayRemove([uid])])
        } catch {
            throw FirebaseError.connection(message: "Failed to establish up-to-date chat info", systemError: error.localizedDescription)
        }
    }
    
    /// Creates a chat in the Firestore chats collection.
    /// - Parameter chat: The chat object to be added to Firestore. This chat object will not have an id property.
    /// Instead, its ID property will be set from within this method.
    func createChat(chat: Chat) async throws -> String {
        do {
//            guard let showId = chat.showId,
//                  try await !chatExists(forShowWithId: showId) else { return "" }

            let chatReference = try await db
                .collection(FbConstants.chats)
                .addDocument(data: [:])

            try chatReference .setData(from: chat) { error in
                if let error {
                    print(error)
                }
            }

            try await chatReference.updateData(["id": chatReference.documentID])
            return chatReference.documentID
        } catch {
            throw FirebaseError.connection(
                message: "Faled to create chat",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Fetches the ChatMessage objects associated with a specific chat.
    /// - Parameter chat: The chat that the fetched messages belong to.
    /// - Returns: An array of all the chat's messages.
    func getMessagesForChat(chat: Chat) async throws -> [ChatMessage] {
        do {
            let chatMessageDocuments = try await db
                .collection(FbConstants.chats)
                .document(chat.id)
                .collection(FbConstants.messages)
                .getDocuments()
            let fetchedChatMessages = try chatMessageDocuments.documents.map { try $0.data(as: ChatMessage.self) }
            
            return fetchedChatMessages
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch chat messages",
                systemError: error.localizedDescription
            )
        }
    }

    func getMessagesForChat(chat: Chat, before timestamp: Double) async throws -> [ChatMessage] {
        do {
            let chatMessageDocuments = try await db
                .collection(FbConstants.chats)
                .document(chat.id)
                .collection(FbConstants.messages)
                .whereField(FbConstants.sentTimestamp, isLessThan: timestamp)
                .order(by: FbConstants.sentTimestamp, descending: true)
                .limit(to: 20)
                .getDocuments()
                .documents

            if let chatMessages = try? chatMessageDocuments.map({ try $0.data(as: ChatMessage.self) }) {
                return chatMessages
            } else {
                throw LogicError.decode(message: "Failed to decode new messages. Please restart The Same Page and try again")
            }
        } catch {
            throw FirebaseError.connection(message: "Failed to fetch new messages", systemError: error.localizedDescription)
        }
    }

    /// Called when a band admin accepts a show invite for their band. This allows the band to gain access to the show's chat.
    /// - Parameters:
    ///   - band: The band that will be joining the chat.
    ///   - showId: The ID of the show that the chat belongs to. Also the value of the show's chat's showId property.
    func addBandToChat(band: Band, showId: String) async throws {
        do {
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
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add band to show chat",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Adds a specific user to a show's chat.
    /// - Parameters:
    ///   - uid: The UID of the user being added to the chat.
    ///   - showId: The ID of the show whose chat the user is getting added to.
    func addUserToChat(user: User, showId: String) async throws {
        do {
            let chatQuery = try await db
                .collection(FbConstants.chats)
                .whereField(FbConstants.showId, isEqualTo: showId)
                .getDocuments()
            
            guard !chatQuery.documents.isEmpty && chatQuery.documents.count == 1 else { return }
            
            let chat = try chatQuery.documents[0].data(as: Chat.self)
            
            try await db
                .collection(FbConstants.chats)
                .document(chat.id)
                .updateData(
                    [
                        FbConstants.participantUids: FieldValue.arrayUnion([user.id]),
                        FbConstants.participantUsernames: FieldValue.arrayUnion([user.name])
                    ]
                )
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(user.name) to chat",
                systemError: error.localizedDescription
            )
        }
    }
    
    func sendChatMessage(chatMessage: ChatMessage, chat: Chat) async throws {
        do {
            _ = try db
                .collection(FbConstants.chats)
                .document(chat.id)
                .collection(FbConstants.messages)
                .addDocument(from: chatMessage)

            try await updateChatWithNewChatMessage(update: chat, with: chatMessage)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to send chat message",
                systemError: error.localizedDescription
            )
        }
    }

    func updateChatWithNewChatMessage(update chat: Chat, with chatMessage: ChatMessage) async throws {
        do {
            _ = try await db
                .collection(FbConstants.chats)
                .document(chat.id)
                .updateData([FbConstants.upToDateParticipantUids: FieldValue.delete()])

            _ = try await db
                .collection(FbConstants.chats)
                .document(chat.id)
                .updateData(
                    [
                        FbConstants.mostRecentMessageText: chatMessage.text,
                        FbConstants.mostRecentMessageTimestamp: chatMessage.sentTimestamp,
                        FbConstants.upToDateParticipantUids: FieldValue.arrayUnion([AuthController.getLoggedInUid()]),
                        FbConstants.mostRecentMessageSenderUsername: AuthController.getLoggedInUsername()
                    ]
                )


        } catch {
            throw FirebaseError.connection(
                message: "Failed to set up-to-date chat info",
                systemError: error.localizedDescription
            )
        }
    }

    func addUserToChatUpToDateParticipantUids(add uid: String, to chat: Chat) async throws {
        do {
            _ = try await db
                .collection(FbConstants.chats)
                .document(chat.id)
                .updateData([FbConstants.upToDateParticipantUids: FieldValue.arrayUnion([AuthController.getLoggedInUid()])])
        } catch {
            throw FirebaseError.connection(
                message: "Failed to update chat data",
                systemError: error.localizedDescription
            )
        }
    }
    
    func deleteChat(for show: Show) async throws {
        do {
            let chatDocument = try await db
                .collection(FbConstants.chats)
                .whereField(FbConstants.showId, isEqualTo: show.id)
                .getDocuments()
                .documents
            
            guard !chatDocument.isEmpty else { return }
            
            let chat = try chatDocument[0].data(as: Chat.self)

            try await FirebaseFunctionsController.recursiveDelete(path: "\(FbConstants.chats)/\(chat.id)")
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete show chat",
                systemError: error.localizedDescription
            )
        }
    }

//    func chatExists(forShowWithId id: String) async throws -> Bool {
//        do {
//            return try await !db
//                .collection(FbConstants.chats)
//                .whereField(FbConstants.showId, isEqualTo: id)
//                .getDocuments()
//                .documents
//                .isEmpty
//        } catch {
//            throw FirebaseError.connection(
//                message: "Failed to fetch chat details",
//                systemError: error.localizedDescription
//            )
//        }
//    }
    
    // MARK: - Firebase Storage

    /// Uploads the image selected by the user to Firebase Storage.
    /// - Parameter image: The image selected by the user.
    /// - Returns: The download URL of the image uploaded to Firebase Storage.
    func uploadImage(image: UIImage) async throws -> String? {
        do {
            let imageData = image.jpegData(compressionQuality: 0.0)
            
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
        } catch {
            throw FirebaseError.connection(
                message: "Failed to upload image",
                systemError: error.localizedDescription
            )
        }
    }

    /// Deletes image from Firebase Storage.
    ///
    /// This method only deletes an image from Firebase Storage, it does not delete the value of an
    /// object's image URL property.
    /// - Parameter url: The URL of the image that is to be deleted.
    func deleteImage(at url: String) async throws {
        do {
            let storageReference = Storage.storage().reference(forURL: url)

            try await storageReference.delete()
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete image",
                systemError: error.localizedDescription
            )
        }
    }

    // MARK: - Firebase Cloud Messaging

    func deleteFcmTokenForUser(withUid uid: String) async throws {
        do {
            try await db
                .collection(FbConstants.users)
                .document(uid)
                .updateData([FbConstants.fcmToken: FieldValue.delete()])
        } catch {
            throw FirebaseError.connection(message: "Failed to complete log out", systemError: error.localizedDescription)
        }
    }

    func updateFcmToken(to newFcmToken: String, forUserWithUid uid: String) async throws {
        do {
            try await db
                .collection(FbConstants.users)
                .document(uid)
                .updateData([FbConstants.fcmToken: newFcmToken])
        } catch {
            throw FirebaseError.connection(message: "Failed to complete log log in", systemError: error.localizedDescription)
        }
    }
}

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            let hScale = newSize.height / size.height
            let vScale = newSize.width / size.width
            let scale = max(hScale, vScale) // scaleToFill
            let resizeSize = CGSize(width: size.width*scale, height: size.height*scale)
            var middle = CGPoint.zero
            if resizeSize.width > newSize.width {
                middle.x -= (resizeSize.width-newSize.width)/2.0
            }
            if resizeSize.height > newSize.height {
                middle.y -= (resizeSize.height-newSize.height)/2.0
            }

            draw(in: CGRect(origin: middle, size: resizeSize))
        }
    }
}
