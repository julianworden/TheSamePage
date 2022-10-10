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
            hostUid: "",
            venue: "Starland Ballroom",
            date: Date().timeIntervalSince1970,
            time: Time.example,
            ticketPrice: 100,
            ticketSalesAreRequired: true,
            minimumRequiredTicketsSold: 20,
            imageUrl: nil,
//            location: Location.example,
            backline: nil,
            hasFood: true,
            hasBar: true,
            is21Plus: false,
            genre: Genre.rock.rawValue,
            maxNumberOfBands: 3,
            bands: [Band.example]
        ),
        Show(
            name: "The Return of Pathetic Fallacy",
            description: "They're back! And with a god damn vengeance you won’t want to miss.",
            host: "Damn Straight Entertainment",
            hostUid: "",
            venue: "Wembley Stadium",
            date: Date().timeIntervalSince1970,
            time: Time.example,
            ticketPrice: 300,
            ticketSalesAreRequired: false,
            minimumRequiredTicketsSold: nil,
            imageUrl: nil,
//            location: Location.example,
            backline: nil,
            hasFood: true,
            hasBar: false,
            is21Plus: false,
            genre: Genre.rock.rawValue,
            maxNumberOfBands: 3,
            bands: [Band.example]
        ),
        Show(
            name: "Generation Underground",
            description: "No idea how they're playing a show this big. They probably paid somebody lots of money.",
            host: "DAA Entertainment",
            hostUid: "",
            venue: "Giants Stadium",
            date: Date().timeIntervalSince1970,
            time: Time.example,
            ticketPrice: 30,
            ticketSalesAreRequired: true,
            minimumRequiredTicketsSold: 10,
            imageUrl: nil,
//            location: Location.example,
            backline: nil,
            hasFood: true,
            hasBar: true,
            is21Plus: true,
            genre: Genre.rock.rawValue,
            maxNumberOfBands: 3,
            bands: [Band.example]
        )
    ]
    
    let db = Firestore.firestore()
    
    // MARK: - Firestore Reads
    
    /// Fetches the logged in user's data from Firestore.
    /// - Returns: The logged in user.
    func getLoggedInUser() async throws -> User {
        guard AuthController.userIsLoggedOut() == false else { throw DatabaseServiceError.firebaseAuthError(message: "User is logged out") }
        
        do {
            let userDocument = try await db.collection("users").document(AuthController.getLoggedInUid()).getDocument()
            return try userDocument.data(as: User.self)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch logged in user")
        }
    }
    
    func getShowsNearYou() -> [Show] {
        return []
    }
    
    // TODO: Make this query the user's hostedShows collection instead
    /// Fetches all the shows of which the signed in user is the host.
    /// - Returns: An array of shows that the signed in user is hosting.
    func getHostedShows() async throws -> [Show] {
        let query = db.collection("shows").whereField("hostUid", isEqualTo: AuthController.getLoggedInUid())
        let yourShows = try await query.getDocuments()
        
        do {
            let showsArray = try yourShows.documents.map { try $0.data(as: Show.self) }
            return showsArray
        } catch {
            throw DatabaseServiceError.decodeError(message: "Failed to decode show from database.")
        }
    }
    
    /// Fetches all the shows in which the signed in user is a participant.
    /// - Returns: All of the shows in which the signed in user is a participant.
    func getPlayingShows() async throws -> [Show] {
        let query = db.collection("shows").whereField("participantUids", arrayContains: AuthController.getLoggedInUid())
        let playingShows = try await query.getDocuments()
        
        do {
            let showsArray = try playingShows.documents.map { try $0.data(as: Show.self) }
            return showsArray
        } catch {
            throw DatabaseServiceError.decodeError(message: "Failed to decode show from database.")
        }
    }
    
    /// Fetches the logged in user's BandInvites from their bandInvites collection.
    /// - Returns: The logged in user's BandInvites.
    func getBandInvites() async throws -> [BandInvite] {
        var bandInvites = [BandInvite]()
        
        do {
            let query = try await db.collection("users").document(AuthController.getLoggedInUid()).collection("bandInvites").getDocuments()
            
            for document in query.documents {
                do {
                    let bandInvite = try document.data(as: BandInvite.self)
                    bandInvites.append(bandInvite)
                } catch {
                    throw DatabaseServiceError.decodeError(message: "Failed to decode bandInvite")
                }
            }
            
            return bandInvites
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch band invites")
        }
    }
    
    /// Fetches the logged in user's showInvites from their showInvites collection.
    /// - Returns: The logged in user's ShowInvites.
    func getShowInvites() async throws -> [ShowInvite] {
        var showInvites = [ShowInvite]()
        
        do {
            let query = try await db.collection("users").document(AuthController.getLoggedInUid()).collection("showInvites").getDocuments()
            
            for document in query.documents {
                do {
                    let showInvite = try document.data(as: ShowInvite.self)
                    showInvites.append(showInvite)
                } catch {
                    throw DatabaseServiceError.decodeError(message: "Failed to decode showInvite")
                }
            }
            
            return showInvites
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch show invites")
        }
    }
    
    /// Fetches a user's bands by using the BandId objects in the bandIds collection of that user.
    /// - Parameter bandIds: The IDs associated with the bands for which the search is occuring.
    /// - Returns: The bands associated with the bandIds.
    func getBands(withBandIds bandIds: [String]) async throws -> [Band] {
        var bands = [Band]()
        guard !bandIds.isEmpty else { bands = []; return bands }
        
        for bandId in bandIds {
            do {
                let band = try await db.collection("bands").document(bandId).getDocument(as: Band.self)
                bands.append(band)
            } catch {
                throw DatabaseServiceError.decodeError(message: "Failed to decode band")
            }
        }
        
        return bands

    }
    
    /// Fetches the id for every band of which a user is a member.
    /// - Parameter uid: The UID of the user whose bands are being queried.
    /// - Returns: The bandId objects associated with the bands of which the user is a member.
    func getIdsForJoinedBands(forUserUid uid: String) async throws -> [String] {
        do {
            let query = try await db.collection("users").document(uid).collection("joinedBands").getDocuments()
            var joinedBands = [String]()
            
            
            
            if !query.documents.isEmpty {
                for document in query.documents {
                    do {
                        let joinedBand = try document.data(as: JoinedBand.self)
                        if joinedBand.id != nil {
                            joinedBands.append(joinedBand.id!)
                        }
                    } catch {
                        throw DatabaseServiceError.decodeError(message: "Failed to decode joinedBand")
                    }
                }
            }
            
            return joinedBands
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch user's joinedBands")
        }
    }
    
    /// Fetches the BandMember objects in a specified band's members collection.
    /// - Parameter band: The band for which the search is occuring.
    /// - Returns: An array of the BandMember objects associated with the band passed into the band parameter.
    func getBandMembers(forBand band: Band) async throws -> [BandMember] {
        guard band.id != nil else { throw DatabaseServiceError.unexpectedNilValue(value: "band.id") }
        var bandMembers = [BandMember]()
        
        do {
            let query = try await db.collection("bands").document(band.id!).collection("members").getDocuments()
            
            for document in query.documents {
                do {
                    let bandMember = try document.data(as: BandMember.self)
                    bandMembers.append(bandMember)
                } catch {
                    throw DatabaseServiceError.decodeError(message: "Failed to decode bandMember")
                }
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch bandMember documents")
        }
        
        return bandMembers
    }
    
    /// Queries Firestore to convert a BandMember object to a User object.
    /// - Parameter bandMember: The BandMember object that will be converted into a User object.
    /// - Returns: The user returned from Firestore that corresponds to the BandMember object passed into the bandMember parameter.
    func convertBandMemberToUser(bandMember: BandMember) async throws -> User {
        do {
            let user = try await db.collection("users").document(bandMember.uid).getDocument(as: User.self)
            return user
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Unable to convert bandMember to user")
        }
    }
    
    /// Fetches a band's links from their links collection.
    /// - Parameter band: The band whose links are to be fetched.
    /// - Returns: An array of the links that the provided band has.
    func getBandLinks(forBand band: Band) async throws -> [PlatformLink] {
        if band.id != nil {
            do {
                var links = [PlatformLink]()
                let query = try await db.collection("bands").document(band.id!).collection("links").getDocuments()
                
                for document in query.documents {
                    do {
                        let link = try document.data(as: PlatformLink.self)
                        links.append(link)
                    } catch {
                        throw DatabaseServiceError.decodeError(message: "Failed to decode Link.")
                    }
                }
                
                return links
            } catch {
                throw DatabaseServiceError.firestoreError(message: "Failed to fetch band links.")
            }
        } else {
            return []
        }
    }
    
    /// Converts a ShowParticipant object to a Band object.
    /// - Parameter showParticipant: The ShowParticipant to be converted.
    /// - Returns: The Band object that the showParticipant was converted into.
    func convertShowParticipantToBand(showParticipant: ShowParticipant) async throws -> Band {
        do {
            let band = try await db.collection("bands").document(showParticipant.bandId).getDocument(as: Band.self)
            return band
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to convert showParticipant to Band.")
        }
    }
    
    func getShowLineup(forShow show: Show) async throws -> [ShowParticipant] {
        guard show.id != nil else { throw DatabaseServiceError.unexpectedNilValue(value: "DatabaseService.getShowLineup(forShow:).show.id") }
        
        let query = try await db.collection("shows").document(show.id!).collection("participants").getDocuments()
        
        do {
            let showParticipants = try query.documents.map { try $0.data(as: ShowParticipant.self) }
            return showParticipants
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
            throw DatabaseServiceError.firestoreError(message: "Failed to add show to database.")
        }
    }
    
    /// Creates a band in the Firestore bands collection.d
    /// - Parameter band: The band to be added to Firestore.
    func createBand(band: Band) async throws -> String {
        do {
            let bandReference = try db.collection("bands").addDocument(from: band)
            try await bandReference.setData(["id": bandReference.documentID], merge: true)
            return bandReference.documentID
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to create band")
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
            throw DatabaseServiceError.firestoreError(message: "Error creating user object.")
        }
        
    }
    
    // TODO: Make this method check if the invited member is already a member of the band
    /// Performs Firestore calls to add a user to a band's members collection, and to add a band to a
    /// user's joinedBands collection. Called when a user accepts a BandInvite.
    /// - Parameters:
    ///   - bandMember: The user that is joining the band in the band parameter.
    ///   - joinedBand: The band that the user from the user parameter is joining.
    ///   - bandInvite: The invite that the user is accepting in order to join the band. If this value is nil, the user joined the band at the time it was created.
    func addUserToBand(_ bandMember: BandMember, addToBand joinedBand: JoinedBand, withBandInvite bandInvite: BandInvite?) throws {
        guard joinedBand.id != nil else { throw DatabaseServiceError.unexpectedNilValue(value: "joinedBand.id") }
        
        do {
            _ = try db.collection("bands").document(joinedBand.id!).collection("members").addDocument(from: bandMember)
            db.collection("users").document(AuthController.getLoggedInUid()).collection("joinedBands").document(joinedBand.id!).setData([:])
            
            if bandInvite != nil {
                deleteBandInvite(bandInvite: bandInvite!)
            }
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to join band. Please check your internet connection and try again.")
        }
    }
    
    /// Deletes a band invite from the logged in user's bandInvites Firestore collection.
    /// - Parameter bandInvite: The band invite to be deleted.
    func deleteBandInvite(bandInvite: BandInvite) {
        if bandInvite.id != nil {
            db.collection("users").document(AuthController.getLoggedInUid()).collection("bandInvites").document(bandInvite.id!).delete()
        }
    }
    
    /// Adds band to show's bands collection, adds show to every member of the band's joinedShows collection (including the
    /// band admin in case they don't play in the band), adds user to show's participants collection. Also deletes the
    /// ShowInvite in the user's showInvites collection.
    /// - Parameter showParticipant: The showParticipant to be added to the Show's participants collection.
    /// - Parameter showInvite: The ShowInvite that was accepted in order for the band to get added to the show.
    func addBandToShow(add showParticipant: ShowParticipant, to joinedShow: JoinedShow, with showInvite: ShowInvite) async throws {
        let bandMembersQuery = try await db.collection("bands").document(showInvite.bandId).collection("members").getDocuments()
        
        // Add the show to every band member's joinedShows collection
        for document in bandMembersQuery.documents {
            let bandMember = try document.data(as: BandMember.self)
            _ = try db.collection("users").document(bandMember.uid).collection("joinedShows").addDocument(from: joinedShow)
        }
        
        // Add the show to the band admin's joinedShows collection
        _ = try db.collection("users").document(showInvite.recipientUid).collection("joinedShows").addDocument(from: joinedShow)
        // Add the show to the band's joinedShows collection
        try await db.collection("bands").document(showInvite.bandId).collection("joinedShows").document(showInvite.showId).setData([:])
        // Add the band to the show's participants collection
        _ = try db.collection("shows").document(showInvite.showId).collection("participants").addDocument(from: showParticipant)
        
        deleteShowInvite(showInvite: showInvite)
    }
    
    /// Deletes a show invite from the logged in user's showInvites collection.
    /// - Parameter showInvite: The ShowInvite to be deleted.
    func deleteShowInvite(showInvite: ShowInvite) {
        if showInvite.id != nil {
            print(showInvite.id!)
            db.collection("users").document(AuthController.getLoggedInUid()).collection("showInvites").document(showInvite.id!).delete()
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
