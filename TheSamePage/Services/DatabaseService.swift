//
//  DatabaseService.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import Foundation
import UIKit.UIImage

class DatabaseService {
    enum DatabaseServiceError: Error {
        case firebaseAuth(message: String)
        case firebaseStorage(message: String)
        case firestore(message: String)
        case decode(message: String)
        case unexpectedNilValue(value: String)
    }
    
    static let shared = DatabaseService()
    
    let db = Firestore.firestore()
    
    // MARK: - Firestore Reads
    
    /// Fetches the logged in user's data from Firestore.
    /// - Returns: The logged in user.
    func getLoggedInUser() async throws -> User {
        guard AuthController.userIsLoggedOut() == false else { throw DatabaseServiceError.firebaseAuth(message: "User is logged out") }
        
        do {
            return try await db.collection("users").document(AuthController.getLoggedInUid()).getDocument().data(as: User.self)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch logged in user")
        }
    }
    
    /// Fetches all the shows of which the signed in user is the host.
    /// - Returns: An array of shows that the signed in user is hosting.
    func getHostedShows() async throws -> [Show] {
        do {
            let query = try await db.collection("shows").whereField("hostUid", isEqualTo: AuthController.getLoggedInUid()).getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: Show.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode show from database.")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch shows in DatabaseService.getHostedShows")
        }
    }
    
    /// Fetches all the shows in which the signed in user is a participant.
    /// - Returns: All of the shows in which the signed in user is a participant.
    func getPlayingShows() async throws -> [Show] {
        do {
            let query = try await db.collection("shows").whereField("participantUids", arrayContains: AuthController.getLoggedInUid()).getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: Show.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode show from database in DatabaseService.getPlayingShows()")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch show participants in DatabaseService.getPlayingShows()")
        }
    }
    
    /// Fetches the logged in user's BandInvites from their bandInvites collection.
    /// - Returns: The logged in user's BandInvites.
    func getBandInvites() async throws -> [BandInvite] {
        do {
            let query = try await db.collection("users").document(AuthController.getLoggedInUid()).collection("bandInvites").getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: BandInvite.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode bandInvite in DatabaseService.getBandInvites()")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch band invites in DatabaseService.getBandInvites()")
        }
    }
    
    /// Fetches the logged in user's showInvites from their showInvites collection.
    /// - Returns: The logged in user's ShowInvites.
    func getShowInvites() async throws -> [ShowInvite] {
        do {
            let query = try await db.collection("users").document(AuthController.getLoggedInUid()).collection("showInvites").getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: ShowInvite.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode showInvite in DatabaseService.getShowinvites()")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch show invites in DatabaseService.getShowinvites()")
        }
    }
    
    /// Fetches all the bands in the bands collection that include a given UID in their memberUids array.
    /// - Parameter uid: The UID for which the search is occuring in the bands' memberUids array.
    /// - Returns: The bands that include the provided UID in the memberUids array.
    func getBands(withUid uid: String) async throws -> [Band] {
        do {
            let query = try await db.collection("bands").whereField("memberUids", arrayContains: uid).getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: Band.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode band in DatabaseService.getBands(withUid:)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch bands in DatabaseService.getBands(withUid:)")
        }
    }
    
    /// Fetches the BandMember objects in a specified band's members collection.
    /// - Parameter band: The band for which the search is occuring.
    /// - Returns: An array of the BandMember objects associated with the band passed into the band parameter.
    func getBandMembers(forBand band: Band) async throws -> [BandMember] {
        do {
            let query = try await db.collection("bands").document(band.id).collection("members").getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: BandMember.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode BandMember in DatabaseService.getBandMembers(forBand:)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch BandMember documents in DatabaseService.getBandMembers(forBand:)")
        }
    }
    
    /// Queries Firestore to convert a BandMember object to a User object.
    /// - Parameter bandMember: The BandMember object that will be converted into a User object.
    /// - Returns: The user returned from Firestore that corresponds to the BandMember object passed into the bandMember parameter.
    func convertBandMemberToUser(bandMember: BandMember) async throws -> User {
        do {
            return try await db.collection("users").document(bandMember.uid).getDocument(as: User.self)
        } catch {
            throw DatabaseServiceError.firestore(message: "Unable to convert BandMember to user in DatabaseService.convertBandMemberToUser(bandMember:)")
        }
    }
    
    /// Fetches a band's links from their links collection.
    /// - Parameter band: The band whose links are to be fetched.
    /// - Returns: An array of the links that the provided band has.
    func getBandLinks(forBand band: Band) async throws -> [PlatformLink] {
        do {
            let query = try await db.collection("bands").document(band.id).collection("links").getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: PlatformLink.self) }
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode Link in DatabaseService.getBandLinks(forBand:)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch band links in DatabaseService.getBandLinks(forBand:)")
        }
    }
    
    /// Converts a ShowParticipant object to a Band object.
    /// - Parameter showParticipant: The ShowParticipant to be converted.
    /// - Returns: The Band object that the showParticipant was converted into.
    func convertShowParticipantToBand(showParticipant: ShowParticipant) async throws -> Band {
        do {
            return try await db.collection("bands").document(showParticipant.bandId).getDocument(as: Band.self)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to convert showParticipant to Band in DatabaseService.convertShowParticipantToBand(showParticipant:)")
        }
    }
    
    func getShowLineup(forShow show: Show) async throws -> [ShowParticipant] {
        let query = try await db.collection("shows").document(show.id).collection("participants").getDocuments()
        
        do {
            return try query.documents.map { try $0.data(as: ShowParticipant.self) }
        } catch {
            throw DatabaseServiceError.decode(message: "Failed to decode ShowParticipant in DatabaseService.getShowLineup(forShow:)")
        }
    }
    
    // MARK: - Firestore Writes
    
    /// Creates a show in the Firestore shows collection and also adds the show's id
    /// to the logged in user's hostedShows collection.
    /// - Parameter show: The show to be added to Firestore.
    func createShow(show: Show) async throws {
        do {
            let showReference = try db.collection("shows").addDocument(from: show)
            try await showReference.updateData(["id": showReference.documentID])
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to add show to database in DatabaseService.createShow(show:)")
        }
    }
    
    func updateShow(show: Show) async throws {
        do {
            try db.collection("shows").document(show.id).setData(from: show, merge: true)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to add show to database in DatabaseService.createShow(show:)")
        }
    }
    
    /// Creates a band in the Firestore bands collection.
    /// - Parameter band: The band to be added to Firestore.
    func createBand(band: Band) async throws -> String {
        do {
            let bandReference = try db.collection("bands").addDocument(from: band)
            try await bandReference.updateData(["id": bandReference.documentID])
            return bandReference.documentID
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to create band in DatabaseService.createBand(band:)")
        }
    }
    
    /// Creates a user object in the Firestore users collection.
    /// - Parameters:
    ///   - user: The user being created in Firestore.
    func createUserObject(user: User) async throws {
        guard AuthController.userIsLoggedOut() == false else { throw DatabaseServiceError.firebaseAuth(message: "User not logged in") }
        
        do {
            try db.collection("users").document(AuthController.getLoggedInUid()).setData(from: user)
        } catch {
            throw DatabaseServiceError.firestore(message: "Error creating user object in DatabaseService.createUserObject(user:)")
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
    func addUserToBand(add bandMember: BandMember, toBandWithId joinedBandId: String, withBandInvite bandInvite: BandInvite?) async throws {
        do {
            _ = try db.collection("bands").document(joinedBandId).collection("members").addDocument(from: bandMember)
            try await db.collection("bands").document(joinedBandId).updateData(["memberUids": FieldValue.arrayUnion([bandMember.uid])])
            
            if bandInvite != nil {
                do {
                    try await deleteBandInvite(bandInvite: bandInvite!)
                } catch {
                    throw error
                }
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Error adding user to band in DatabaseService.addUserToBand(add:toBandWithId:withBandInvite:)")
        }
    }
    
    /// Deletes a band invite from the logged in user's bandInvites Firestore collection.
    /// - Parameter bandInvite: The band invite to be deleted.
    func deleteBandInvite(bandInvite: BandInvite) async throws {
        if bandInvite.id != nil {
            do {
                try await db.collection("users").document(AuthController.getLoggedInUid()).collection("bandInvites").document(bandInvite.id!).delete()
            } catch {
                throw DatabaseServiceError.firestore(message: "Failed to delete BandInvite in DatabaseService.deleteBandInvite(bandInvite:)")
            }
        }
    }
    
    /// Adds band to show's bands collection, adds show to every member of the band's joinedShows collection (including the
    /// band admin in case they don't play in the band), adds user to show's participants collection. Also deletes the
    /// ShowInvite in the user's showInvites collection.
    /// - Parameter showParticipant: The showParticipant to be added to the Show's participants collection.
    /// - Parameter showInvite: The ShowInvite that was accepted in order for the band to get added to the show.
    func addBandToShow(add showParticipant: ShowParticipant, withShowInvite showInvite: ShowInvite) async throws {
        do {
            // Add showParticipant to the show's participants collection
            _ = try db.collection("shows").document(showInvite.showId).collection("participants").addDocument(from: showParticipant)
            
            // Add the band's ID to the show's bandIds property
            try await db.collection("shows").document(showInvite.showId).updateData(["bandIds": FieldValue.arrayUnion([showInvite.bandId])])
            
            // Get the band object so that the members are accessible
            let band = try await db.collection("bands").document(showInvite.bandId).getDocument(as: Band.self)
            
            if !band.memberUids.isEmpty {
                try await db.collection("shows").document(showInvite.showId).updateData(["participantUids": FieldValue.arrayUnion(band.memberUids)])
                try await addBandToChat(band: band, showId: showInvite.showId)
            }
            
            // Check to see if the band admin is already in the memberUids array. If it isn't, add it to the show's participantUids property.
            if !band.memberUids.contains(showInvite.recipientUid) {
                try await db.collection("shows").document(showInvite.showId).updateData(["participantUids": FieldValue.arrayUnion([showInvite.recipientUid])])
                try await addUserToChat(uid: showInvite.recipientUid, showId: showInvite.showId)
            }
            
            do {
                try await deleteShowInvite(showInvite: showInvite)
            } catch {
                throw error
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to add band to show in DatabaseService.addBandToShow(add:to:with:)")
        }
    }
    
    /// Called when a band admin accepts a show invite for their band. This allows the band to gain access to the show's chat.
    /// - Parameters:
    ///   - band: The band that will be joining the chat.
    ///   - showId: The ID of the show that the chat belongs to. Also the value of the show's chat's showId property.
    func addBandToChat(band: Band, showId: String) async throws {
        do {
            let chatQuery = try await db.collection("chats").whereField("showId", isEqualTo: showId).getDocuments()
            
            guard !chatQuery.documents.isEmpty && chatQuery.documents.count == 1 else { return }
            
            do {
                let chat = try chatQuery.documents[0].data(as: Chat.self)
                try await db.collection("chats").document(chat.id).updateData(["participantUids": FieldValue.arrayUnion(band.memberUids)])
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode Chat in DatabaseService.addBandToChat(withShowInvite:)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch Chat in DatabaseService.addBandToChat(withShowInvite:)")
        }
    }
    
    func addUserToChat(uid: String, showId: String) async throws {
        do {
            let chatQuery = try await db.collection("chats").whereField("showId", isEqualTo: showId).getDocuments()
            
            guard !chatQuery.documents.isEmpty && chatQuery.documents.count == 1 else { return }
            
            do {
                let chat = try chatQuery.documents[0].data(as: Chat.self)
                try await db.collection("chats").document(chat.id).updateData(["participantUids": FieldValue.arrayUnion([uid])])
            } catch {
                throw DatabaseServiceError.decode(message: "Failed to decode Chat in DatabaseService.addUserToChat(uid:showId)")
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch Chat in DatabaseService.addUserToChat(uid:showId)")
        }
    }
    
    func addTimeToShow(addTime time: Date, ofType showTimeType: ShowTimeType, forShow show: Show) async throws {
        do {
            switch showTimeType {
            case .loadIn:
                try await db.collection("shows").document(show.id).updateData(["loadInTime": time.timeIntervalSince1970])
            case .musicStart:
                try await db.collection("shows").document(show.id).updateData(["musicStartTime": time.timeIntervalSince1970])
            case .end:
                try await db.collection("shows").document(show.id).updateData(["endTime": time.timeIntervalSince1970])
            case .doors:
                try await db.collection("shows").document(show.id).updateData(["doorsTime": time.timeIntervalSince1970])
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to add time to show in in DatabaseService.addTimeToShow(addTime:ofType:forShow)")
        }
    }
    
    func deleteTimeFromShow(delete showTimeType: ShowTimeType, fromShow show: Show) async throws {
        do {
            switch showTimeType {
            case .loadIn:
                try await db.collection("shows").document(show.id).updateData(["loadInTime": FieldValue.delete()])
            case .musicStart:
                try await db.collection("shows").document(show.id).updateData(["musicStartTime": FieldValue.delete()])
            case .end:
                try await db.collection("shows").document(show.id).updateData(["endTime": FieldValue.delete()])
            case .doors:
                try await db.collection("shows").document(show.id).updateData(["doorsTime": FieldValue.delete()])
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to delete show time in DatabaseService.deleteTimeFromShow(delete:fromShow:)")
        }
    }
    
    /// Deletes a show invite from the logged in user's showInvites collection.
    /// - Parameter showInvite: The ShowInvite to be deleted.
    func deleteShowInvite(showInvite: ShowInvite) async throws {
        if showInvite.id != nil {
            do {
                try await db.collection("users").document(AuthController.getLoggedInUid()).collection("showInvites").document(showInvite.id!).delete()
            } catch {
                throw DatabaseServiceError.firestore(message: "Failed to delete BandInvite in DatabaseService.deleteShowInvite(showInvite:)")
            }
        }
    }
    
    /// Adds a social media link to a band's links collection.
    /// - Parameters:
    ///   - link: The link to be added to the band's links collection.
    ///   - band: The band that the link belongs to.
    func uploadBandLink(withLink link: PlatformLink, forBand band: Band) throws {
        _ = try db.collection("bands").document(band.id).collection("links").addDocument(from: link)
    }
    
    // MARK: - Notifications
    
    /// Sends an invitation to a user to join a band. Uploads a BandInvite object to the specified user's bandInvites collection in
    /// Firestore.
    /// - Parameter invite: The BandInvite that is being sent.
    func sendBandInvite(invite: BandInvite) throws {
        do {
            _ = try db.collection("users")
                .document(invite.recipientUid)
                .collection("bandInvites")
                .addDocument(from: invite)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to send bandInvite.")
        }
    }
    
    /// Sends an invitation to a band's admin to have their band join a show. Uploads a ShowInvite object
    /// to the specified user's showInvites collection in Firestore.
    /// - Parameter invite: The ShowInvite that is being sent.
    func sendShowInvite(invite: ShowInvite) throws {
        do {
            _ = try db.collection("users")
                .document(invite.recipientUid)
                .collection("showInvites")
                .addDocument(from: invite)
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to send showInvite.")
        }
    }
    
    func addBacklineItemToShow(backlineItem: BacklineItem?, drumKitBacklineItem: DrumKitBacklineItem?, show: Show) throws {
        do {
            if let backlineItem {
                _ = try db.collection("shows").document(show.id).collection("backlineItems").addDocument(from: backlineItem)
            }
            
            if let drumKitBacklineItem {
                _ = try db.collection("shows").document(show.id).collection("backlineItems").addDocument(from: drumKitBacklineItem)
            }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to add backlineItem to show in DatabaseService.addBacklineItemToShow(add:to:)")
        }
    }
    
    func getBacklineItems(forShow show: Show) async throws -> [BacklineItem] {
        do {
            let query = try await db.collection("shows").document(show.id).collection("backlineItems").getDocuments()
            return try query.documents.map { try $0.data(as: BacklineItem.self) }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch backlineItems for show in DatabaseService.getBacklineItems(forShow:)")
        }
    }
    
    func getDrumKitBacklineItems(forShow show: Show) async throws -> [DrumKitBacklineItem] {
        do {
            let query = try await db.collection("shows").document(show.id).collection("backlineItems").getDocuments()
            return try query.documents.map { try $0.data(as: DrumKitBacklineItem.self) }
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch backlineItems for show in DatabaseService.getDrumKitBacklineItems(forShow:)")
        }
    }
    
    // MARK: - Firebase Storage
    
    // TODO: Make this method delete the previous profile image if the user is replacing an existing image
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
            throw DatabaseServiceError.firebaseStorage(message: "Error setting profile picture")
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
            try await db.collection("shows").document(show.id).updateData(["imageUrl": newImageUrl])
        }
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
            try await db.collection("users").document(user.id).updateData(["profileImageUrl": newImageUrl])
        }
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
            try await db.collection("bands").document(band.id).updateData(["profileImageUrl": newImageUrl])
        }
    }
    
    func getChat(withShowId showId: String) async throws -> Chat? {
        let chat = try await db.collection("chats").whereField("showId", isEqualTo: showId).getDocuments()
        
        // Each show should only have 1 chat
        guard !chat.documents.isEmpty && chat.documents[0].exists && chat.documents.count == 1 else { return nil }
        
        do {
            let fetchedChat = try chat.documents[0].data(as: Chat.self)
            return fetchedChat
        } catch {
            throw DatabaseServiceError.decode(message: "Failed to decode Chat in DatabaseService.getChat(withShowId:)")
        }
    }
    
    func createChat(chat: Chat) async throws {
        do {
            let chatReference = try db.collection("chats").addDocument(from: chat)
            try await chatReference.updateData(["id": chatReference.documentID])
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to create new chat in DatabaseService.createChat(chat:)")
        }
    }
    
    func getMessagesForChat(chat: Chat) async throws -> [ChatMessage] {
        do {
            let chatMessageDocuments = try await db.collection("chats").document(chat.id).collection("messages").getDocuments()
            let fetchedChatMessages = try chatMessageDocuments.documents.map { try $0.data(as: ChatMessage.self) }
            return fetchedChatMessages
        } catch {
            throw DatabaseServiceError.firestore(message: "Failed to fetch chat messages in DatabaseService.getMessagesForChat(chat:)")
        }
    }
}
