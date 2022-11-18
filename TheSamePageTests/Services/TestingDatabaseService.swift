//
//  TestingDatabaseService.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/17/22.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

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
    
    func showExists(showId: String) async throws -> Bool {
        do {
            return try await db
                .collection(FbConstants.shows)
                .document(showId)
                .getDocument()
                .exists
        } catch {
            throw TestingDatabaseServiceError.firestore(message: "Failed to determine if show exists in DatabaseService.showExists(show:) Error: \(error.localizedDescription)")
        }
    }
    
    func getShowName(showId: String) async throws -> String {
        do {
            return try await db
                .collection(FbConstants.shows)
                .document(showId)
                .getDocument(as: Show.self)
                .name
        } catch {
            throw TestingDatabaseServiceError.firestore(message: "Failed to fetch show name in TestingDatabaseService.getShowName(showId:) Error: \(error)")
        }
    }
    
    func getImageUrl(showId: String) async throws -> String? {
        do {
            let show = try await db
                .collection(FbConstants.shows)
                .document(showId)
                .getDocument(as: Show.self)
            
            return show.imageUrl
        }
    }
    
    /// A convenience method for testing that allows for a show document to be deleted. This method is for testing and
    /// should not be used in production, as it does not account for any subcollections a document may have.
    /// - Parameter showId: The document ID of the show to be deleted.
    func deleteShowObject(showId: String) async throws {
        do {
            try await db
                .collection(FbConstants.shows)
                .document(showId)
                .delete()
        } catch {
            throw TestingDatabaseServiceError.firestore(message: "Failed to delete show in DatabaseService.deleteShowObject(showId:) Error \(error.localizedDescription)")
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
}
