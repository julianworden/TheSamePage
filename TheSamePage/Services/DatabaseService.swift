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
                .document(AuthController.getLoggedInUid())
                .setData(from: user)
        } catch {
            throw FirebaseError.connection(
                message: "There was an error creating your account",
                systemError: error.localizedDescription
            )
        }
    }
    
    func newUsernameIsValid(_ username: String) async throws -> Bool {
        do {
            let newUsernameIsValid = try await db
                .collection(FbConstants.users)
                .whereField(FbConstants.username, isEqualTo: username)
                .getDocuments()
                .documents
                .isEmpty
            
            return newUsernameIsValid
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
    
    /// Fetches all the shows of which the signed in user is the host.
    /// - Returns: An array of shows that the signed in user is hosting.
    func getHostedShows() async throws -> [Show] {
        do {
            let query = try await db
                .collection(FbConstants.shows)
                .whereField("hostUid", isEqualTo: AuthController.getLoggedInUid())
                .getDocuments()
            
            return try query.documents.map { try $0.data(as: Show.self) }
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
    func removeUserFromBand(user: User, band: Band) async throws {
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
            
            let bandMemberDocumentId = try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.members)
                .whereField(FbConstants.uid, isEqualTo: user.id)
                .getDocuments()
                .documents[0]
                .documentID
            
            try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.members)
                .document(bandMemberDocumentId)
                .delete()
            
            let userShows = try await getShowsForBand(band: band)
            
            if !userShows.isEmpty {
                for show in userShows {
                    try await removeUserFromShow(user: user, show: show)
                    
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
    
    func removeUserFromChat(user: User, chat: Chat) async throws {
        do {
            try await db
                .collection(FbConstants.chats)
                .document(chat.id)
                .updateData(
                    [
                        FbConstants.participantUids: FieldValue.arrayRemove([user.id]),
                        FbConstants.participantFcmTokens: (user.fcmToken != nil ? FieldValue.arrayRemove([user.fcmToken!]) : FieldValue.arrayRemove([]))
                    ]
                )
        } catch {
            throw FirebaseError.connection(
                message: "Failed to remove you from \(chat.name ?? "chat")",
                systemError: error.localizedDescription
            )
        }
    }
    
    func removeUserFromShow(user: User, show: Show) async throws {
        do {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([FbConstants.participantUids: FieldValue.arrayRemove([user.id])])
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
    func getBands(withUid uid: String) async throws -> [Band] {
        do {
            let query = try await db
                .collection(FbConstants.bands)
                .whereField("memberUids", arrayContains: uid)
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
    
    
    // MARK: - Bands
    
    
    func getBand(with id: String) async throws -> Band {
        do {
            return try await db
                .collection(FbConstants.bands)
                .document(id)
                .getDocument(as: Band.self)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch band",
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
                .document(band.id).collection("members")
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
                try await deleteBandInvite(bandInvite: bandInvite)
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
    
    /// Deletes a band invite from the logged in user's bandInvites Firestore collection.
    /// - Parameter bandInvite: The band invite to be deleted.
    func deleteBandInvite(bandInvite: BandInvite) async throws {
        do {
            try await db
                .collection(FbConstants.users)
                .document(bandInvite.recipientUid)
                .collection(FbConstants.notifications)
                .document(bandInvite.id)
                .delete()
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete band invite from notifications list",
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
    
    
    // MARK: - Shows

    func getLatestShowData(showId: String) async throws -> Show {
        do {
            return try await db
                .collection(FbConstants.shows)
                .document(showId)
                .getDocument(as: Show.self)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to fetch latest show data. Please check your internet connection and try again.",
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
            
            
            try await deleteShowInvite(showInvite: showInvite)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(band.name) to \(showInvite.showName)",
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
                    .updateData(
                        [
                            FbConstants.participantUids: FieldValue.arrayUnion([user.id]),
                            FbConstants.participantFcmTokens: (user.fcmToken != nil ? FieldValue.arrayUnion([user.fcmToken!]) : FieldValue.arrayUnion([]))
                        ]
                    )
            }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(user.username) to \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    func addTimeToShow(addTime time: Date, ofType showTimeType: ShowTimeType, forShow show: Show) async throws {
        do {
            switch showTimeType {
            case .loadIn:
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(["loadInTime": time.timeIntervalSince1970])
            case .musicStart:
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(["musicStartTime": time.timeIntervalSince1970])
            case .end:
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(["endTime": time.timeIntervalSince1970])
            case .doors:
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(["doorsTime": time.timeIntervalSince1970])
            }
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(showTimeType.rawValue) time to \(show.name)",
                systemError: error.localizedDescription
            )
        }
    }
    
    func deleteTimeFromShow(delete showTimeType: ShowTimeType, fromShow show: Show) async throws {
        do {
            switch showTimeType {
            case .loadIn:
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(["loadInTime": FieldValue.delete()])
            case .musicStart:
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(["musicStartTime": FieldValue.delete()])
            case .end:
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(["endTime": FieldValue.delete()])
            case .doors:
                try await db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .updateData(["doorsTime": FieldValue.delete()])
            }
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
    
    func getBacklineItems(forShow show: Show) async throws -> QuerySnapshot {
        do {
            return try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection("backlineItems")
                .getDocuments()
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
    
    /// Deletes a show invite from the logged in user's showInvites collection.
    /// - Parameter showInvite: The ShowInvite to be deleted.
    func deleteShowInvite(showInvite: ShowInvite) async throws {
        do {
            try await db
                .collection(FbConstants.users)
                .document(AuthController.getLoggedInUid())
                .collection(FbConstants.notifications)
                .document(showInvite.id)
                .delete()

        } catch {
            throw FirebaseError.connection(
                message: "Failed to elete show invite from notifications list",
                systemError: error.localizedDescription
            )
        }
    }
    
    func cancelShow(show: Show) async throws {
        do {
            _ = try await Functions.functions().httpsCallable(FbConstants.recursiveDelete).call([FbConstants.path: "\(FbConstants.shows)/\(show.id)"])
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

    func deleteBacklineItem(delete backlineItem: BacklineItem, inShowWithId showId: String) async throws {
        guard let backlineItemId = backlineItem.id else {
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
    
    // MARK: - Chats

    /// Fetches the chat that belongs to a given show.
    /// - Parameter showId: The ID of the show that the fetched chat is associated with.
    /// - Returns: The fetched chat associated with the show passed into the showId property. Returns nil if no chat is found for a show.
    /// It is up to the caller to determine what actions to take when nil is returned.
    func getChat(withShowId showId: String) async throws -> Chat? {
        do {
            let chat = try await db
                .collection(FbConstants.chats)
                .whereField("showId", isEqualTo: showId)
                .getDocuments()
            
            // Each show should only have 1 chat
            guard !chat.documents.isEmpty && chat.documents[0].exists && chat.documents.count == 1 else { return nil }
            
            let fetchedChat = try chat.documents[0].data(as: Chat.self)
            return fetchedChat
        } catch {
            throw FirebaseError.connection(
                message: "Failed to get fetch show chat",
                systemError: error.localizedDescription
            )
        }
    }
    
    /// Creates a chat in the Firestore chats collection.
    /// - Parameter chat: The chat object to be added to Firestore. This chat object will not have an id property.
    /// Instead, its ID property will be set from within this method.
    func createChat(chat: Chat) async throws -> String {
        do {
            let chatReference = try db
                .collection(FbConstants.chats)
                .addDocument(from: chat)
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
                .updateData(
                    [
                        FbConstants.participantUids: FieldValue.arrayUnion(band.memberUids),
                        FbConstants.participantFcmTokens: FieldValue.arrayUnion(band.memberFcmTokens)
                    ]
                )
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
                        FbConstants.participantFcmTokens: (user.fcmToken != nil ? FieldValue.arrayUnion([user.fcmToken!]) : FieldValue.arrayUnion([]))
                    ]
                )
        } catch {
            throw FirebaseError.connection(
                message: "Failed to add \(user.username) to chat",
                systemError: error.localizedDescription
            )
        }
    }
    
    func sendChatMessage(chatMessage: ChatMessage, chat: Chat) throws {
        do {
            _ = try db
                .collection(FbConstants.chats)
                .document(chat.id)
                .collection(FbConstants.messages)
                .addDocument(from: chatMessage)
        } catch {
            throw FirebaseError.connection(
                message: "Failed to send chat message",
                systemError: error.localizedDescription
            )
        }
    }
    
    func getChatFcmTokens(withUids uids: [String]) async throws -> [String] {
        do {
            var fetchedFcmTokens = [String]()
            
            for uid in uids {
                let fetchedUser = try await db
                    .collection(FbConstants.users)
                    .document(uid).getDocument(as: User.self)
                if let fcmToken = fetchedUser.fcmToken {
                    fetchedFcmTokens.append(fcmToken)
                }
            }
            
            return fetchedFcmTokens
        } catch {
            throw FirebaseError.connection(
                message: "Failed to set chat data",
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
            
            _ = try await Functions.functions().httpsCallable(FbConstants.recursiveDelete).call([FbConstants.recursiveDelete: "\(FbConstants.chats)/\(chat.id)"])
        } catch {
            throw FirebaseError.connection(
                message: "Failed to delete show chat",
                systemError: error.localizedDescription
            )
        }
    }
    
    // MARK: - Firebase Storage

    /// Uploads the image selected by the user to Firebase Storage.
    /// - Parameter image: The image selected by the user.
    /// - Returns: The download URL of the image uploaded to Firebase Storage.
    func uploadImage(image: UIImage) async throws -> String? {
        do {
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
}
