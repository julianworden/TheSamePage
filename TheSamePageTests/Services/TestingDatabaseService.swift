//
//  TestingDatabaseService.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/17/22.
//

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

    // MARK: - Firestore

    func getUserFromFirestore(_ user: User) async throws -> User {
        return try await db
            .collection(FbConstants.users)
            .document(user.id)
            .getDocument(as: User.self)
    }

    func getShow(_ show: Show) async throws -> Show {
        do {
            return try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .getDocument(as: Show.self)
        }
    }

    func getBand(_ band: Band) async throws -> Band {
        return try await db
            .collection(FbConstants.bands)
            .document(band.id)
            .getDocument(as: Band.self)
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
    func deleteShow(_ show: Show) async throws {
        do {
            try await db
                .collection(FbConstants.shows)
                .document(show.id)
                .delete()
        } catch {
            throw TestingDatabaseServiceError.firestore(message: "Failed to delete show in DatabaseService.deleteShowObject(showId:) Error \(error.localizedDescription)")
        }
    }

    // MARK: - Firebase Storage

    func getDownloadLinkForUserProfileImage(_ user: User) async throws -> String {
        guard let imageUrl = user.profileImageUrl else {
            return ""
        }

        let imageRef = Storage.storage().reference(forURL: imageUrl)
        return try await imageRef.downloadURL().absoluteString
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

    // MARK: - Firebase Auth

    @discardableResult func logInToTestAccount() async throws -> FirebaseAuth.User? {
        do {
            let result = try await Auth.auth().signIn(withEmail: "julianworden@gmail.com", password: "dynomite")
            return result.user
        } catch {
            return nil
        }
    }

    func getLoggedInUserFromFirebaseAuth() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }

    func logOutOfTestAccount() throws {
        try Auth.auth().signOut()
    }

    func userIsLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
