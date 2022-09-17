//
//  Concert.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

struct Show: Codable, Identifiable {
    // TODO: Replace all id properties on all Models with a @DocumentID property from Firebase
    let id: UUID
    let name: String
    let description: String?
    let host: User
    let participantUids: [String]
    let venueName: String
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
        id: UUID(),
        name: "Dumpweed Extravaganza",
        description: "A dank ass banger! Hop on the bill I freakin’ swear you won’t regret it! Like, it's gonna be the show of the absolute century, bro!",
        host: User.example,
        participantUids: [],
        venueName: "Starland Ballroom",
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
