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

class DatabaseService: NSObject {
    enum DatabaseServiceError: Error {
        case firebaseAuth(message: String)
        case firebaseStorage(message: String)
        case firestore(message: String)
        case decode(message: String)
        case unexpectedNilValue(value: String)
    }
    
    static let shared = DatabaseService()
    
    let db = Firestore.firestore()
    
    
    // MARK: - Users
    
    
    /// Creates a user object in the Firestore users collection.
    /// - Parameters:
    ///   - user: The user being created in Firestore.
    func createUserObject(user: User) async throws {
        guard AuthController.userIsLoggedOut() == false else { throw DatabaseServiceError.firebaseAuth(message: "User not logged in") }
        
        do {
            try db.collection(FbConstants.users).document(AuthController.getLoggedInUid()).setData(from: user)
        } catch {
            throw DatabaseServiceError.firestore(message: "Error creating user object in DatabaseService.createUserObject(user:) Error: \(error)")
        }
        
    }
    
    /// Fetches the logged in user's data from Firestore.
    /// - Returns: The logged in user.
    func getLoggedInUser() async throws -> User {
        guard AuthController.userIsLoggedOut() == false else { throw DatabaseServiceError.firebaseAuth(message: "User is logged out") }
        
        do {
            return try await db.collection(FbConstants.users).document(AuthController.getLoggedInUid()).getDocument().data(as: User.self)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch logged in user in DatabaseService.getLoggedInUser(). Error: \(error)")
        }
    }
        
    /// Fetches all the shows of which the signed in user is the host.
    /// - Returns: An array of shows that the signed in user is hosting.
    func getHostedShows() async throws -> [Show] {
        do {
            let query = try await db.collection(FbConstants.shows).whereField("hostUid", isEqualTo: AuthController.getLoggedInUid()).getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: Show.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode show from database. Error: \(error)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch shows in DatabaseService.getHostedShows Error: \(error)")
        }
    }
    
    /// Fetches all the shows in which the signed in user is a participant.
    /// - Returns: All of the shows in which the signed in user is a participant.
    func getPlayingShows() async throws -> [Show] {
        do {
            let query = try await db.collection(FbConstants.shows).whereField("participantUids", arrayContains: AuthController.getLoggedInUid()).getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: Show.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode show from database in DatabaseService.getPlayingShows() Error: \(error)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch show participants in DatabaseService.getPlayingShows() Error: \(error)")
        }
    }
    
    /// Fetches the logged in user's BandInvites from their bandInvites collection.
    /// - Returns: The logged in user's BandInvites.
    func getNotifications() async throws -> [AnyUserNotification] {
        var anyUserNotifications = [AnyUserNotification]()
        
        do {
            let query = try await db
                .collection(FbConstants.users)
                .document(AuthController.getLoggedInUid())
                .collection(FbConstants.notifications)
                .getDocuments()
            
            for document in query.documents {
                if let bandInvite = try? document.data(as: BandInvite.self) {
                    let anyUserNotification = AnyUserNotification(id: bandInvite.id!, notification: bandInvite)
                    anyUserNotifications.append(anyUserNotification)
                } else if let showInvite = try? document.data(as: ShowInvite.self) {
                    let anyUserNotification = AnyUserNotification(id: showInvite.id!, notification: showInvite)
                    anyUserNotifications.append(anyUserNotification)
                }
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch notifications in DatabaseService.getNotifications() Error: \(error)")
        }
        
        return anyUserNotifications
    }
    
    /// Updates the profileImageUrl associated with a user, uploads the new image to Firebase Storage,
    /// and deletes the old image from Firebase Storage, if it existed.
    /// - Parameters:
    ///   - image: The new image to be uploaded to Firebase Storage.
    ///   - user: The user that will be having its profileImageUrl property updated.
    func updateUserProfileImage(image: UIImage, user: User) async throws {
        if let oldImageUrl = user.profileImageUrl {
            let oldImageRef = Storage.storage().reference(forURL: oldImageUrl)
            try await oldImageRef.delete()
        }
        
        if let newImageUrl = try await uploadImage(image: image) {
            try await db.collection(FbConstants.users)
                .document(user.id)
                .updateData(["profileImageUrl": newImageUrl])
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
            throw DatabaseServiceError.firestore(message: "Failed to remove user from band in DatabaseService.removeUserFromBand(user:band:). Error: \(error)")
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
            throw DatabaseServiceError.firestore(message: "Failed to remove user from chat in DatabaseService.removeUserFromChat(user:chat:). Error: \(error)")
        }
    }
    
    func removeUserFromShow(user: User, show: Show) async throws {
        do {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .updateData([FbConstants.participantUids: FieldValue.arrayRemove([user.id])])
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to remove user from show in DatabaseService.removeUserFromShow(user:show:) Error: \(error)")
        }
    }
    
    /// Fetches all the bands in the bands collection that include a given UID in their memberUids array.
    /// - Parameter uid: The UID for which the search is occuring in the bands' memberUids array.
    /// - Returns: The bands that include the provided UID in the memberUids array.
    func getBands(withUid uid: String) async throws -> [Band] {
        do {
            let query = try await db.collection(FbConstants.bands).whereField("memberUids", arrayContains: uid).getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: Band.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode band in DatabaseService.getBands(withUid:) Error: \(error)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch bands in DatabaseService.getBands(withUid:) Error: \(error)")
        }
    }
    
    /// Queries Firestore to convert a BandMember object to a User object.
    /// - Parameter bandMember: The BandMember object that will be converted into a User object.
    /// - Returns: The user returned from Firestore that corresponds to the BandMember object passed into the bandMember parameter.
    func convertBandMemberToUser(bandMember: BandMember) async throws -> User {
        do {
            return try await db.collection(FbConstants.users).document(bandMember.uid).getDocument(as: User.self)
        } catch {
            throw DatabaseServiceError.firestore(message: "Unable to convert BandMember to user in DatabaseService.convertBandMemberToUser(bandMember:) Error: \(error)")
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
            throw DatabaseServiceError.firestore(message: "Failed to fetch logged in user in DatabaseService.getBand(with:). Error: \(error)")
        }
    }
    
    /// Fetches all of the shows that a band is playing.
    /// - Parameter band: The band for which the show search is taking place.
    /// - Returns: The shows that the given band is playing.
    func getShowsForBand(band: Band) async throws -> [Show] {
        do {
            let showsQuery = try await db.collection(FbConstants.shows).whereField("bandIds", arrayContains: band.id).getDocuments()
            
            do {
                let fetchedShows = try showsQuery.documents.map { try $0.data(as: Show.self) }
                return fetchedShows
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode show in DabaseService.getShowsForBand(band:) Error: \(error)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch band's shows in DabaseService.getShowsForBand(band:) Error: \(error)")
        }
    }
    
    /// Fetches the BandMember objects in a specified band's members collection.
    /// - Parameter band: The band for which the search is occuring.
    /// - Returns: An array of the BandMember objects associated with the band passed into the band parameter.
    func getBandMembers(forBand band: Band) async throws -> [BandMember] {
        do {
            let query = try await db.collection(FbConstants.bands).document(band.id).collection("members").getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: BandMember.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode BandMember in DatabaseService.getBandMembers(forBand:) Error: \(error)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch BandMember documents in DatabaseService.getBandMembers(forBand:) Error: \(error)")
        }
    }
    
    /// Creates a band in the Firestore bands collection.
    /// - Parameter band: The band to be added to Firestore.
    func createBand(band: Band) async throws -> String {
        do {
            let bandReference = try db.collection(FbConstants.bands).addDocument(from: band)
            try await bandReference.updateData(["id": bandReference.documentID])
            return bandReference.documentID
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to create band in DatabaseService.createBand(band:) Error: \(error)")
        }
    }
    
    func updateBand(band: Band) async throws {
        do {
            try db.collection(FbConstants.bands).document(band.id).setData(from: band, merge: true)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to update band in DatabaseService.updateBand(band:) Error: \(error)")
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
    func addUserToBand(add user: User, as bandMember: BandMember, to band: Band, withBandInvite bandInvite: BandInvite?) async throws {
        do {
            _ = try db
                .collection(FbConstants.bands)
                .document(band.id)
                .collection(FbConstants.members)
                .addDocument(from: bandMember)
            
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
                do {
                    try await deleteBandInvite(bandInvite: bandInvite)
                } catch {
                    throw error
                }
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Error adding user to band in DatabaseService.addUserToBand(add:toBandWithId:withBandInvite:) Error: \(error)")
        }
    }
    
    /// Adds a social media link to a band's links collection.
    /// - Parameters:
    ///   - link: The link to be added to the band's links collection.
    ///   - band: The band that the link belongs to.
    func uploadBandLink(withLink link: PlatformLink, forBand band: Band) throws {
        _ = try db
            .collection(FbConstants.bands)
            .document(band.id)
            .collection("links")
            .addDocument(from: link)
    }
    
    /// Updates the profileImageUrl associated with a band, uploads the new image to Firebase Storage,
    /// and deletes the old image from Firebase Storage, if it existed.
    /// - Parameters:
    ///   - image: The new image to be uploaded to Firebase Storage.
    ///   - band: The band that will be having its profileImageUrl property updated.
    func updateBandProfileImage(image: UIImage, band: Band) async throws {
        if let oldImageUrl = band.profileImageUrl {
            let oldImageRef = Storage.storage().reference(forURL: oldImageUrl)
            try await oldImageRef.delete()
        }
        
        if let newImageUrl = try await uploadImage(image: image) {
            try await db
                .collection(FbConstants.bands)
                .document(band.id)
                .updateData(["profileImageUrl": newImageUrl])
        }
    }
    
    /// Sends an invitation to a user to join a band. Uploads a BandInvite object to the specified user's bandInvites collection in
    /// Firestore.
    /// - Parameter invite: The BandInvite that is being sent.
    func sendBandInvite(invite: BandInvite) throws {
        do {
            _ = try db
                .collection(FbConstants.users)
                .document(invite.recipientUid)
                .collection(FbConstants.notifications)
                .addDocument(from: invite)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to send bandInvite.")
        }
    }
    
    /// Deletes a band invite from the logged in user's bandInvites Firestore collection.
    /// - Parameter bandInvite: The band invite to be deleted.
    func deleteBandInvite(bandInvite: BandInvite) async throws {
        if let bandInviteId = bandInvite.id {
            do {
                try await db
                    .collection(FbConstants.users)
                    .document(AuthController.getLoggedInUid())
                    .collection(FbConstants.notifications)
                    .document(bandInviteId)
                    .delete()
            } catch {
                throw DatabaseServiceError.firestore(message: "Failed to delete BandInvite in DatabaseService.deleteBandInvite(bandInvite:) Error: \(error)")
            }
        }
    }
    
    /// Fetches a band's links from their links collection.
    /// - Parameter band: The band whose links are to be fetched.
    /// - Returns: An array of the links that the provided band has.
    func getBandLinks(forBand band: Band) async throws -> [PlatformLink] {
        do {
            let query = try await db.collection(FbConstants.bands).document(band.id).collection("links").getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: PlatformLink.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode Link in DatabaseService.getBandLinks(forBand:) Error: \(error)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch band links in DatabaseService.getBandLinks(forBand:) Error: \(error)")
        }
    }
    
    /// Converts a ShowParticipant object to a Band object.
    /// - Parameter showParticipant: The ShowParticipant to be converted.
    /// - Returns: The Band object that the showParticipant was converted into.
    func convertShowParticipantToBand(showParticipant: ShowParticipant) async throws -> Band {
        do {
            return try await db.collection(FbConstants.bands).document(showParticipant.bandId).getDocument(as: Band.self)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to convert showParticipant to Band in DatabaseService.convertShowParticipantToBand(showParticipant:) Error: \(error)")
        }
    }
        
    
    // MARK: - Shows
    
    
    /// Creates a show in the Firestore shows collection and also adds the show's id
    /// to the logged in user's hostedShows collection.
    /// - Parameter show: The show to be added to Firestore.
    func createShow(show: Show) async throws -> String {
        do {
            let showReference = try db.collection(FbConstants.shows).addDocument(from: show)
            try await showReference.updateData(["id": showReference.documentID])
            return showReference.documentID
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to add show to database in DatabaseService.createShow(show:) Error: \(error)")
        }
    }
    
    func getShowLineup(forShow show: Show) async throws -> [ShowParticipant] {
        let query = try await db.collection(FbConstants.shows).document(show.id).collection("participants").getDocuments()
        
        do {
            return try query.documents.map { try $0.data(as: ShowParticipant.self) }
        } catch {
            throw DatabaseServiceError.decode(message: "Failed to decode ShowParticipant in DatabaseService.getShowLineup(forShow:) Error: \(error)")
        }
    }
    
    func updateShow(show: Show) async throws {
        do {
            try db.collection(FbConstants.shows).document(show.id).setData(from: show, merge: true)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to update show in DatabaseService.updateShow(show:) Error: \(error)")
        }
    }
    
    func showProfilePictureExists(showImageUrl: String?) async throws -> Bool {
        guard let showImageUrl else { return false }
        
        let storageReference = Storage.storage().reference(forURL: showImageUrl)
        
        do {
            let downloadUrl = try await storageReference.downloadURL().absoluteString
            
            if downloadUrl.isEmpty {
                return false
            } else {
                return true
            }
        } catch {
            return false
        }
    }
    
    /// Updates the imageUrl associated with a show, uploads the new image to Firebase Storage,
    /// and deletes the old image from Firebase Storage, if it existed.
    /// - Parameters:
    ///   - image: The new image to be uploaded to Firebase Storage.
    ///   - show: The show that will be having its imageUrl property updated.
    func updateShowImage(image: UIImage, show: Show) async throws {
        // Delete old image if it exists
        if let oldImageUrl = show.imageUrl {
            let oldImageRef = Storage.storage().reference(forURL: oldImageUrl)
            try await oldImageRef.delete()
        }
        
        if let newImageUrl = try await uploadImage(image: image) {
            try await db.collection(FbConstants.shows).document(show.id).updateData(["imageUrl": newImageUrl])
        }
    }
    
    /// Sends an invitation to a band's admin to have their band join a show. Uploads a ShowInvite object
    /// to the specified user's showInvites collection in Firestore.
    /// - Parameter invite: The ShowInvite that is being sent.
    func sendShowInvite(invite: ShowInvite) throws {
        do {
            _ = try db
                .collection(FbConstants.users)
                .document(invite.recipientUid)
                .collection(FbConstants.notifications)
                .addDocument(from: invite)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to send showInvite.")
        }
    }
    
    /// Adds band to show's bands collection, adds show to every member of the band's joinedShows collection (including the
    /// band admin in case they don't play in the band), adds user to show's participants collection. Also deletes the
    /// ShowInvite in the user's showInvites collection.
    /// - Parameter showParticipant: The showParticipant to be added to the Show's participants collection.
    /// - Parameter showInvite: The ShowInvite that was accepted in order for the band to get added to the show.
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
                .updateData([FbConstants.bandIds: FieldValue.arrayUnion([showInvite.bandId])])
            
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
            if !band.memberUids.contains(showInvite.recipientUid) {
                let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
                try await db
                    .collection(FbConstants.shows)
                    .document(showInvite.showId)
                    .updateData(["participantUids": FieldValue.arrayUnion([showInvite.recipientUid])])
                try await addUserToChat(user: loggedInUser, showId: showInvite.showId)
            }
            
            do {
                try await deleteShowInvite(showInvite: showInvite)
            } catch {
                throw error
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to add band to show in DatabaseService.addBandToShow(add:to:with:) Error: \(error)")
        }
    }
    
    func addUserToShow(add user: User, to show: Show) async throws {
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
            throw DatabaseServiceError.firestore(message: "Failed to add time to show in in DatabaseService.addTimeToShow(addTime:ofType:forShow) Error: \(error)")
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
            throw DatabaseServiceError.firestore(message: "Failed to delete show time in DatabaseService.deleteTimeFromShow(delete:fromShow:) Error: \(error)")
        }
    }
    
    func addBacklineItemToShow(backlineItem: BacklineItem?, drumKitBacklineItem: DrumKitBacklineItem?, show: Show) throws {
        do {
            if let backlineItem {
                _ = try db.collection(FbConstants.shows)
                    .document(show.id)
                    .collection("backlineItems")
                    .addDocument(from: backlineItem)
            }
            
            if let drumKitBacklineItem {
                _ = try db
                    .collection(FbConstants.shows)
                    .document(show.id)
                    .collection("backlineItems")
                    .addDocument(from: drumKitBacklineItem)
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to add backlineItem to show in DatabaseService.addBacklineItemToShow(add:to:)")
        }
    }
    
    func getBacklineItems(forShow show: Show) async throws -> [BacklineItem] {
        do {
            let query = try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .collection("backlineItems")
                .getDocuments()
            return try query.documents.map { try $0.data(as: BacklineItem.self) }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch backlineItems for show in DatabaseService.getBacklineItems(forShow:)")
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
            throw DatabaseServiceError.firestore(message: "Failed to fetch backlineItems for show in DatabaseService.getDrumKitBacklineItems(forShow:)")
        }
    }
    
    /// Deletes a show invite from the logged in user's showInvites collection.
    /// - Parameter showInvite: The ShowInvite to be deleted.
    func deleteShowInvite(showInvite: ShowInvite) async throws {
        if let showInviteId = showInvite.id {
            do {
                try await db
                    .collection(FbConstants.users)
                    .document(AuthController.getLoggedInUid())
                    .collection(FbConstants.notifications)
                    .document(showInviteId)
                    .delete()
            } catch {
                throw DatabaseServiceError.firestore(message: "Failed to delete BandInvite in DatabaseService.deleteShowInvite(showInvite:) Error: \(error)")
            }
        }
    }
    
    func cancelShow(show: Show?, showId: String? = nil) async throws {
        do {
            if let show {
                _ = try await Functions.functions().httpsCallable("recursiveDelete").call(["path": "shows/\(show.id)"])
                try await deleteChat(for: show)
            } else if let showId {
                _ = try await Functions.functions().httpsCallable("recursiveDelete").call(["path": "shows/\(showId)"])
            }
            
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to delete show in DatabaseService.cancelShow(show:) Error: \(error)")
        }
    }
    
    // MARK: - Chats
    /// Fetches the chat that belongs to a given show.
    /// - Parameter showId: The ID of the show that the fetched chat is associated with.
    /// - Returns: The fetched chat associated with the show passed into the showId property. Returns nil if no chat is found for a show.
    /// It is up to the caller to determine what actions to take when nil is returned.
    func getChat(withShowId showId: String) async throws -> Chat? {
        let chat = try await db
            .collection(FbConstants.chats)
            .whereField("showId", isEqualTo: showId)
            .getDocuments()
        
        // Each show should only have 1 chat
        guard !chat.documents.isEmpty && chat.documents[0].exists && chat.documents.count == 1 else { return nil }
        
        do {
            let fetchedChat = try chat.documents[0].data(as: Chat.self)
            return fetchedChat
        } catch {
            throw DatabaseServiceError.decode(message: "Failed to decode Chat in DatabaseService.getChat(withShowId:) Error: \(error)")
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
            throw DatabaseServiceError.firestore(message: "Failed to create new chat in DatabaseService.createChat(chat:) Error: \(error.localizedDescription)")
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
            throw DatabaseServiceError.firestore(message: "Failed to fetch chat messages in DatabaseService.getMessagesForChat(chat:) Error: \(error)")
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
            
            do {
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
                throw DatabaseServiceError.decode(message: "Failed to decode Chat in DatabaseService.addBandToChat(withShowInvite:) Error: \(error)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch Chat in DatabaseService.addBandToChat(withShowInvite:) Error: \(error)")
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
            
            do {
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
                throw DatabaseServiceError.decode(message: "Failed to decode Chat in DatabaseService.addUserToChat(uid:showId) Error: \(error)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch Chat in DatabaseService.addUserToChat(uid:showId) Error: \(error)")
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
            throw DatabaseServiceError.firestore(message: "Failed to send mesage in DatabaseService.sendChatMessage(chatMessage:chat:) Error: \(error)")
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
            throw DatabaseServiceError.firestore(message: "Failed to fetch FCM Tokens from Firestore in DatabaseService.getFcmTokens(withUids:) Error: \(error)")
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
            
            _ = try await Functions.functions().httpsCallable("recursiveDelete").call(["path": "chats/\(chat.id)"])
            print("Delete successful")
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to delete chat in DatabaseService.deleteChat(for:) Error: \(error)")
        }
    }
    
    
    // MARK: - Firebase Storage
    
    
    /// Uploads the image selected by the user to Firebase Storage.
    /// - Parameter image: The image selected by the user.
    /// - Returns: The download URL of the image uploaded to Firebase Storage.
    func uploadImage(image: UIImage) async throws -> String? {
        let imageData = image.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            throw DatabaseServiceError.unexpectedNilValue(value: "imageData")
        }
        
        let storageRef = Storage.storage().reference()
        let path = "images/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        var imageUrl: URL?
        
        do {
            _ = try await fileRef.putDataAsync(imageData!)
            let fetchedImageUrl = try await fileRef.downloadURL()
            imageUrl = fetchedImageUrl
            return imageUrl?.absoluteString
        } catch {
            throw DatabaseServiceError.firebaseStorage(message: "Error setting profile picture. Error: \(error)")
        }
    }
    
    func deleteImage(at url: String) async throws {
        let storageReference = Storage.storage().reference(forURL: url)
        do {
            try await storageReference.delete()
        } catch {
            throw DatabaseServiceError.firebaseStorage(message: "Failed to delete image in DatabaseService.deleteImage(at:) Error \(error.localizedDescription)")
        }
    }
}
