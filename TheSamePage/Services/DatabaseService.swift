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
        case firebaseAuthError(message: String)
        case firebaseStorageError(message: String)
        case firestoreError(message: String)
        case decodeError(message: String)
        case unexpectedNilValue(value: String)
    }
    
    static let shared = DatabaseService()
    static let shows = [
        Show(
            name: "Dumpweed Extravaganza",
            description: "A dank ass banger! Hop on the bill I freakin’ swear you won’t regret it I swear.",
            host: "DAA Entertainment",
            hostUid: "awefawefawefawef",
            venue: "Starland Ballroom",
            date: Date().timeIntervalSince1970,
            ticketPrice: 100,
            ticketSalesAreRequired: true,
            minimumRequiredTicketsSold: 20,
            addressIsPubliclyVisible: true,
            address: "Starland Ballroom's address here",
            city: "Sayreville",
            state: "NJ",
            latitude: 2341234,
            longitude: 123412341,
            geohash: "ja;wijfawi;efj",
            hasFood: true,
            hasBar: true,
            is21Plus: false,
            genre: Genre.rock.rawValue,
            maxNumberOfBands: 3
        ),
        Show(
            name: "The Return of Pathetic Fallacy",
            description: "They're back! And with a god damn vengeance you won’t want to miss.",
            host: "Damn Straight Entertainment",
            hostUid: "asdfawefawef",
            venue: "Wembley Stadium",
            date: Date().timeIntervalSince1970,
            ticketPrice: 300,
            ticketSalesAreRequired: false,
            addressIsPubliclyVisible: true,
            address: "Wembley Stadium's address here",
            city: "Some City",
            state: "England",
            latitude: 2341234,
            longitude: 123412341,
            geohash: "ja;wijfawi;efj",
            imageUrl: nil,
            hasFood: true,
            hasBar: false,
            is21Plus: false,
            genre: Genre.rock.rawValue,
            maxNumberOfBands: 3
        ),
        Show(
            name: "Generation Underground",
            description: "No idea how they're playing a show this big. They probably paid somebody lots of money.",
            host: "DAA Entertainment",
            hostUid: "awefawefawefawef",
            venue: "Giants Stadium",
            date: Date().timeIntervalSince1970,
            ticketPrice: 30,
            ticketSalesAreRequired: true,
            minimumRequiredTicketsSold: 10,
            addressIsPubliclyVisible: true,
            address: "Giant stadium address here",
            city: "NY",
            state: "NY",
            latitude: 23452345,
            longitude: 45234234,
            geohash: "asfergrtgh",
            hasFood: true,
            hasBar: true,
            is21Plus: true,
            genre: Genre.rock.rawValue,
            maxNumberOfBands: 3
        )
    ]
    
    let db = Firestore.firestore()
    
    // MARK: - Firestore Reads
    
    /// Fetches the logged in user's data from Firestore.
    /// - Returns: The logged in user.
    func getLoggedInUser() async throws -> User {
        guard AuthController.userIsLoggedOut() == false else { throw DatabaseServiceError.firebaseAuthError(message: "User is logged out") }
        
        do {
            return try await db.collection("users").document(AuthController.getLoggedInUid()).getDocument().data(as: User.self)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch logged in user")
        }
    }
    
    func getShowsNearYou() -> [Show] {
        return []
    }
    
    /// Fetches all the shows of which the signed in user is the host.
    /// - Returns: An array of shows that the signed in user is hosting.
    func getHostedShows() async throws -> [Show] {
        do {
            let query = try await db.collection("shows").whereField("hostUid", isEqualTo: AuthController.getLoggedInUid()).getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: Show.self) }
            } catch {
                throw DatabaseServiceError.decodeError(message: "Failed to decode show from database.")
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch shows in DatabaseService.getHostedShows")
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
                throw DatabaseServiceError.decodeError(message: "Failed to decode show from database in DatabaseService.getPlayingShows()")
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch show participants in DatabaseService.getPlayingShows()")
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
                throw DatabaseServiceError.decodeError(message: "Failed to decode bandInvite in DatabaseService.getBandInvites()")
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch band invites in DatabaseService.getBandInvites()")
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
                throw DatabaseServiceError.decodeError(message: "Failed to decode showInvite in DatabaseService.getShowinvites()")
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch show invites in DatabaseService.getShowinvites()")
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
                throw DatabaseServiceError.decodeError(message: "Failed to decode band in DatabaseService.getBands(withUid:)")
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch bands in DatabaseService.getBands(withUid:)")
        }
    }
    
    /// Fetches the BandMember objects in a specified band's members collection.
    /// - Parameter band: The band for which the search is occuring.
    /// - Returns: An array of the BandMember objects associated with the band passed into the band parameter.
    func getBandMembers(forBand band: Band) async throws -> [BandMember] {
        guard band.id != nil else { throw DatabaseServiceError.unexpectedNilValue(value: "band.id") }
        
        do {
            let query = try await db.collection("bands").document(band.id!).collection("members").getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: BandMember.self) }
            } catch {
                throw DatabaseServiceError.decodeError(message: "Failed to decode BandMember in DatabaseService.getBandMembers(forBand:)")
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch BandMember documents in DatabaseService.getBandMembers(forBand:)")
        }
    }
    
    /// Queries Firestore to convert a BandMember object to a User object.
    /// - Parameter bandMember: The BandMember object that will be converted into a User object.
    /// - Returns: The user returned from Firestore that corresponds to the BandMember object passed into the bandMember parameter.
    func convertBandMemberToUser(bandMember: BandMember) async throws -> User {
        do {
            return try await db.collection("users").document(bandMember.uid).getDocument(as: User.self)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Unable to convert BandMember to user in DatabaseService.convertBandMemberToUser(bandMember:)")
        }
    }
    
    /// Fetches a band's links from their links collection.
    /// - Parameter band: The band whose links are to be fetched.
    /// - Returns: An array of the links that the provided band has.
    func getBandLinks(forBand band: Band) async throws -> [PlatformLink] {
        guard band.id != nil else { return [] }
        
        do {
            let query = try await db.collection("bands").document(band.id!).collection("links").getDocuments()
            
            do {
                return try query.documents.map { try $0.data(as: PlatformLink.self) }
            } catch {
                throw DatabaseServiceError.decodeError(message: "Failed to decode Link in DatabaseService.getBandLinks(forBand:)")
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch band links in DatabaseService.getBandLinks(forBand:)")
        }
    }
    
    /// Converts a ShowParticipant object to a Band object.
    /// - Parameter showParticipant: The ShowParticipant to be converted.
    /// - Returns: The Band object that the showParticipant was converted into.
    func convertShowParticipantToBand(showParticipant: ShowParticipant) async throws -> Band {
        do {
            return try await db.collection("bands").document(showParticipant.bandId).getDocument(as: Band.self)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to convert showParticipant to Band in DatabaseService.convertShowParticipantToBand(showParticipant:)")
        }
    }
    
    func getShowLineup(forShow show: Show) async throws -> [ShowParticipant] {
        guard show.id != nil else { throw DatabaseServiceError.unexpectedNilValue(value: "DatabaseService.getShowLineup(forShow:).show.id") }
        
        let query = try await db.collection("shows").document(show.id!).collection("participants").getDocuments()
        
        do {
            return try query.documents.map { try $0.data(as: ShowParticipant.self) }
        } catch {
            throw DatabaseServiceError.decodeError(message: "Failed to decode ShowParticipant in DatabaseService.getShowLineup(forShow:)")
        }
    }
    
    // MARK: - Firestore Writes
    
    /// Creates a show in the Firestore shows collection and also adds the show's id
    /// to the logged in user's hostedShows collection.
    /// - Parameter show: The show to be added to Firestore.
    func createShow(show: Show) async throws {
        do {
            let showReference = try db.collection("shows").addDocument(from: show)
            try await showReference.setData(["id": showReference.documentID], merge: true)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to add show to database in DatabaseService.createShow(show:)")
        }
    }
    
    /// Creates a band in the Firestore bands collection.
    /// - Parameter band: The band to be added to Firestore.
    func createBand(band: Band) async throws -> String {
        do {
            let bandReference = try db.collection("bands").addDocument(from: band)
            try await bandReference.setData(["id": bandReference.documentID], merge: true)
            return bandReference.documentID
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to create band in DatabaseService.createBand(band:)")
        }
    }
    
    /// Creates a user object in the Firestore users collection.
    /// - Parameters:
    ///   - user: The user being created in Firestore.
    func createUserObject(user: User) async throws {
        guard AuthController.userIsLoggedOut() == false else { throw DatabaseServiceError.firebaseAuthError(message: "User not logged in") }
        
        do {
            try db.collection("users").document(AuthController.getLoggedInUid()).setData(from: user)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Error creating user object in DatabaseService.createUserObject(user:)")
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
            throw DatabaseServiceError.firestoreError(message: "Error adding user to band in DatabaseService.addUserToBand(add:toBandWithId:withBandInvite:)")
        }
    }
    
    /// Deletes a band invite from the logged in user's bandInvites Firestore collection.
    /// - Parameter bandInvite: The band invite to be deleted.
    func deleteBandInvite(bandInvite: BandInvite) async throws {
        if bandInvite.id != nil {
            do {
                try await db.collection("users").document(AuthController.getLoggedInUid()).collection("bandInvites").document(bandInvite.id!).delete()
            } catch {
                throw DatabaseServiceError.firestoreError(message: "Failed to delete BandInvite in DatabaseService.deleteBandInvite(bandInvite:)")
            }
        }
    }
    
    /// Adds band to show's bands collection, adds show to every member of the band's joinedShows collection (including the
    /// band admin in case they don't play in the band), adds user to show's participants collection. Also deletes the
    /// ShowInvite in the user's showInvites collection.
    /// - Parameter showParticipant: The showParticipant to be added to the Show's participants collection.
    /// - Parameter showInvite: The ShowInvite that was arunccepted in order for the band to get added to the show.
    func addBandToShow(add showParticipant: ShowParticipant, withShowInvite showInvite: ShowInvite) async throws {
        do {
            // Add showParticipant to the show's showParticipants collection
            _ = try db.collection("shows").document(showInvite.showId).collection("participants").addDocument(from: showParticipant)
            
            // Add the band's ID to the show's bandIds property
            try await db.collection("shows").document(showInvite.showId).updateData(["bandIds": FieldValue.arrayUnion([showInvite.bandId])])
            
            // Get the band object so that the members are accessible
            let band = try await db.collection("bands").document(showInvite.bandId).getDocument(as: Band.self)
            
            if !band.memberUids.isEmpty {
                try await db.collection("shows").document(showInvite.showId).updateData(["participantUids": FieldValue.arrayUnion(band.memberUids)])
            }
            
            // Check to see if the band admin is already in the memberUids array. If it isn't, add it to the show's participantUids property.
            if !band.memberUids.contains(showInvite.recipientUid) {
                try await db.collection("shows").document(showInvite.showId).updateData(["participantUids": FieldValue.arrayUnion([showInvite.recipientUid])])
            }
            
            do {
                try await deleteShowInvite(showInvite: showInvite)
            } catch {
                throw error
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to add band to show in DatabaseService.addBandToShow(add:to:with:)")
        }
        
    }
    
    func addTimeToShow(addTime time: Date, ofType showTimeType: ShowTimeType, forShow show: Show) async throws {
        guard show.id != nil else {
            throw DatabaseServiceError.unexpectedNilValue(value: "show.id in DatabaseService.addTimeToShow(addTime:ofType:forShow)")
        }
        
        do {
            switch showTimeType {
            case .loadIn:
                try await db.collection("shows").document(show.id!).updateData(["loadInTime": time.timeIntervalSince1970])
            case .musicStart:
                try await db.collection("shows").document(show.id!).updateData(["musicStartTime": time.timeIntervalSince1970])
            case .end:
                try await db.collection("shows").document(show.id!).updateData(["endTime": time.timeIntervalSince1970])
            case .doors:
                try await db.collection("shows").document(show.id!).updateData(["doorsTime": time.timeIntervalSince1970])
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to add time to show in in DatabaseService.addTimeToShow(addTime:ofType:forShow)")
        }
    }
    
    func deleteTimeFromShow(delete showTimeType: ShowTimeType, fromShow show: Show) async throws {
        guard show.id != nil else { throw DatabaseServiceError.unexpectedNilValue(value: "show.id in DatabaseService.deleteTimeFromShow(delete:fromShow:)")}
        
        do {
            switch showTimeType {
            case .loadIn:
                try await db.collection("shows").document(show.id!).updateData(["loadInTime": FieldValue.delete()])
            case .musicStart:
                try await db.collection("shows").document(show.id!).updateData(["musicStartTime": FieldValue.delete()])
            case .end:
                try await db.collection("shows").document(show.id!).updateData(["endTime": FieldValue.delete()])
            case .doors:
                try await db.collection("shows").document(show.id!).updateData(["doorsTime": FieldValue.delete()])
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to delete show time in DatabaseService.deleteTimeFromShow(delete:fromShow:)")
        }
    }
    
    /// Deletes a show invite from the logged in user's showInvites collection.
    /// - Parameter showInvite: The ShowInvite to be deleted.
    func deleteShowInvite(showInvite: ShowInvite) async throws {
        if showInvite.id != nil {
            do {
                try await db.collection("users").document(AuthController.getLoggedInUid()).collection("showInvites").document(showInvite.id!).delete()
            } catch {
                throw DatabaseServiceError.firestoreError(message: "Failed to delete BandInvite in DatabaseService.deleteShowInvite(showInvite:)")
            }
        }
    }
    
    /// Adds a social media link to a band's links collection.
    /// - Parameters:
    ///   - link: The link to be added to the band's links collection.
    ///   - band: The band that the link belongs to.
    func uploadBandLink(withLink link: PlatformLink, forBand band: Band) throws {
        if band.id != nil {
            _ = try db.collection("bands").document(band.id!).collection("links").addDocument(from: link)
        }
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
            throw DatabaseServiceError.firestoreError(message: "Failed to send bandInvite.")
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
            throw DatabaseServiceError.firestoreError(message: "Failed to send showInvite.")
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
            throw DatabaseServiceError.firebaseStorageError(message: "Error setting profile picture")
        }
    }
}
