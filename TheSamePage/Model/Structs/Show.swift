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
        description: nil,
        host: User.example,
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
