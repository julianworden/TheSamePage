//
//  Location.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

struct Location: Codable {
    let address: String
    let latitude: String
    let longitude: String
    let geohash: String
    
    static let example = Location(
        address: "4 Shorebrook Circle, Neptune NJ",
        latitude: "",
        longitude: "",
        geohash: ""
    )
}
