//
//  Concert.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// TODO: Add a participant uid collection for a showParticipants collection on shows
struct Show: Codable, Equatable, Hashable, Identifiable {
    var id: String?
    let name: String
    let description: String?
    let host: String
    let hostUid: String
    let venue: String
    let date: Double
    let time: Time?
    let ticketPrice: Double?
    let imageUrl: String?
//    let location: Location
    let backline: Backline?
    let hasFood: Bool
    let hasBar: Bool
    let is21Plus: Bool
    let genre: String
    let maxNumberOfBands: Int
    let bands: [Band]?
    
    var formattedDate: String? {
        return TextUtility.formatDate(unixDate: date)
    }
    
    var formattedDoorsTime: String? {
        if let time {
            return TextUtility.formatTime(time: time.doors?.dateValue() ?? Date())
        } else {
            return nil
        }
    }
    
    var loggedInUserIsShowHost: Bool {
        return hostUid == AuthController.getLoggedInUid()
    }
    
    static let example = Show(
        name: "Dumpweed Extravaganza",
        description: "A dank ass banger! Hop on the bill I freakin’ swear you won’t regret it! Like, it's gonna be the show of the absolute century, bro!",
        host: "DAA Entertainment",
        hostUid: "",
        venue: "Starland Ballroom",
        date: Date().timeIntervalSince1970,
        time: Time.example,
        ticketPrice: 100,
        imageUrl: nil,
//        location: Location.example,
        backline: nil,
        hasFood: true,
        hasBar: true,
        is21Plus: false,
        genre: Genre.rock.rawValue,
        maxNumberOfBands: 2,
        bands: nil
    )
}
