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
            participantUids: [],
            venue: "Starland Ballroom",
            date: Timestamp(date: Date()),
            time: Time.example,
            ticketPrice: 100,
            imageUrl: nil,
            location: Location.example,
            backline: nil,
            hasFood: true,
            hasBar: true,
            is21Plus: false,
            genre: nil,
            maxNumberOfBands: 3,
            bands: [Band.example]
        ),
        Show(
            name: "The Return of Pathetic Fallacy",
            description: "They're back! And with a god damn vengeance you won’t want to miss.",
            host: "Damn Straight Entertainment",
            hostUid: "",
            participantUids: [],
            venue: "Wembley Stadium",
            date: Timestamp(date: Date()),
            time: Time.example,
            ticketPrice: 200,
            imageUrl: nil,
            location: Location.example,
            backline: nil,
            hasFood: true,
            hasBar: false,
            is21Plus: false,
            genre: nil,
            maxNumberOfBands: 3,
            bands: [Band.example]
        ),
        Show(
            name: "Generation Underground",
            description: "No idea how they're playing a show this big. They probably paid somebody lots of money.",
            host: "DAA Entertainment",
            hostUid: "",
            participantUids: [],
            venue: "Giants Stadium",
            date: Timestamp(date: Date()),
            time: Time.example,
            ticketPrice: 300,
            imageUrl: nil,
            location: Location.example,
            backline: nil,
            hasFood: true,
            hasBar: true,
            is21Plus: true,
            genre: nil,
            maxNumberOfBands: 3,
            bands: [Band.example]
        )
    ]
    
    let db = Firestore.firestore()
    
    // MARK: - Firestore Reads
    
    /// Fetches the logged in user's data from Firestore.
    ///
    /// Used to initialize the logged in user within UserController so that basic data (first name, last name, profile image URL, etc.) is
    /// readily available on device.
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
    
    /// Fetches the logged in user's notifications from their Firestore bandInvites collection.
    /// - Returns: The logged in user's notifications.
    func getNotifications() async throws -> [BandInvite] {
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
                }ands
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
    
    // MARK: - Firestore Writes
    
    /// Creates a show in the Firestore shows collection.
    /// - Parameter show: The show to be added to Firestore.
    func createShow(show: Show) throws {
        do {
            _ = try db.collection("shows").addDocument(from: show)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to add show to database.")
        }
    }
    
    /// Creates a band in the Firestore bands collection.d
    /// - Parameter band: The band to be added to Firestore.
    func createBand(band: Band) throws -> String {
        do {
            let bandReference = try db.collection("bands").addDocument(from: band)
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
    
    /// Performs Firestore calls to add a user to a band's members collection, and to add a band to a
    /// user's bandIds collection.
    /// - Parameters:
    ///   - user: The user that is joining the band in the band parameter.
    ///   - band: The band that the user from the user parameter is joining.
    func addUserToBand(_ user: BandMember, addToBandUserJoined joinedBand: JoinedBand) throws {
        guard joinedBand.id != nil else { throw DatabaseServiceError.unexpectedNilValue(value: "band.id") }
        
        // TODO: Turn this into a transaction?
        do {
            _ = try db.collection("bands").document(joinedBand.id!).collection("members").addDocument(from: user)
            db.collection("users").document(AuthController.getLoggedInUid()).collection("joinedBands").document(joinedBand.id!).setData([:])
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to join band. Please check your internet connection and try again.")
        }
    }
    
    func declineBandInvite() async throws {
        
    }
    
    // MARK: - Firestore Searches
    
    /// Fetches a band that the user searches for so it can be displayed in a List.
    /// - Parameter name: The name of the band for which the user is searching.
    /// - Returns: The bands that match the name the user searched for.
    func searchForBands(name: String) async throws -> [Band] {
        do {
            var bandsArray = [Band]()
            let query = try await db.collection("bands").whereField("name", isEqualTo: name).getDocuments()
            
            for document in query.documents {
                do {
                    let band = try document.data(as: Band.self)
                    bandsArray.append(band)
                } catch {
                    throw DatabaseServiceError.decodeError(message: "Failed to decode band")
                }
            }
            
            return bandsArray
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to retrieve band documents")
        }
    }
    
    /// Searches for users based on their email address (will later work with usernames when I incorporate usernames).
    /// - Parameter emailAddress: The email address for which the user searched.
    /// - Returns: The users that match that email address.
    func searchForUsers(emailAddress: String) async throws -> [User] {
        do {
            var usersArray = [User]()
            let query = try await db.collection("users").whereField("emailAddress", isEqualTo: emailAddress).getDocuments()
            
            for document in query.documents {
                do {
                    let user = try document.data(as: User.self)
                    usersArray.append(user)
                } catch {
                    throw DatabaseServiceError.decodeError(message: "Failed to decode user")
                }
            }
            
            return usersArray
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to retrieve user documents")
        }
    }
    
    // MARK: - Notifications
    
    /// Sends an invitation to a user to join a band.
    ///
    /// Uploads an invite object to the specified user's bandInvites collection in Firestore. Eventually, this will trigger a notification for the user.
    /// - Parameter invite: The invite that is being sent.
    func sendBandInvite(invite: BandInvite) throws {
        do {
            _ = try db.collection("users")
                .document(invite.recipientUid)
                .collection("bandInvites")
                .addDocument(from: invite)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to set bandInvites property.")
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
