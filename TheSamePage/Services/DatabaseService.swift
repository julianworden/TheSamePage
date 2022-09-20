//
//  DatabaseService.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import Foundation

class DatabaseService {
    enum DatabaseServiceError: Error {
        case firestoreError(message: String)
        case decodeError(message: String)
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
}
