//
//  DatabaseService.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseAuth
import FirebaseFirestore
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
    
    // MARK: - Firestore
    
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
    
    func createShow(show: Show) throws {
        do {
            _ = try db.collection("shows").addDocument(from: show)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to add show to database.")
        }
    }
    
    /// Creates a user object in the Firestore users collection.
    ///
    /// If the user added a profile picture when signing up, this method will call a subsequent method to
    /// upload that image to Firebase storage and gain access to that image's URL.
    /// - Parameters:
    ///   - firstName: The first name entered by the user.
    ///   - lastName: The last name entered by the user.
    ///   - image: The profile picture selected by the user.
    func createUserObject(firstName: String, lastName: String, image: UIImage?) async throws {
        guard AuthController.userIsLoggedOut() == false else { throw DatabaseServiceError.firebaseAuthError(message: "User not logged in") }
        
        let document = db.collection("users").document(AuthController.getLoggedInUid())

        if let image = image {
            do {
                let imageUrl = try await DatabaseService.shared.uploadImage(image: image)
                let newUser = User(
                    firstName: firstName,
                    lastName: lastName,
                    profileImageUrl: imageUrl ?? "",
                    phoneNumber: nil,
                    emailAddress: nil,
                    bands: nil
                )
                try document.setData(from: newUser)
            } catch {
                throw DatabaseServiceError.firebaseStorageError(message: "Error setting profile picture")
            }
        } else if image == nil {
            let newUser = User(
                firstName: firstName,
                lastName: lastName,
                profileImageUrl: nil,
                phoneNumber: nil,
                emailAddress: nil,
                bands: nil
            )
            do {
                try document.setData(from: newUser)
            } catch {
                throw DatabaseServiceError.firestoreError(message: "Failed to set new user data")
            }
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
    
    // MARK: - User
    
    func initializeUser() async throws -> User {
        guard AuthController.userIsLoggedOut() == false else { throw DatabaseServiceError.firebaseAuthError(message: "User is logged out") }
        
        do {
            let userDocument = try await db.collection("users").document(AuthController.getLoggedInUid()).getDocument()
            return try userDocument.data(as: User.self)
        } catch {
            throw DatabaseServiceError.firestoreError(message: "Failed to fetch logged in user")
        }
    }
}
