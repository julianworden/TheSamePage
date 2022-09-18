//
//  Concert.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct Show: Codable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var dateCreated: Timestamp?
    let name: String
    let description: String?
    let host: String
    let hostUid: String
    let participantUids: [String]
    let venue: String
    let date: Timestamp
    let time: Time
    let ticketPrice: Double?
    let imageUrl: String?
    let location: Location
    let backline: Backline?
    let hasFood: Bool
    let hasBar: Bool
    let is21Plus: Bool
    let genre: Genre?
    let bands: [Band]?
    
    static let example = Show(
        name: "Dumpweed Extravaganza",
        description: "A dank ass banger! Hop on the bill I freakin’ swear you won’t regret it! Like, it's gonna be the show of the absolute century, bro!",
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
        bands: nil
    )
}
