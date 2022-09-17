//
//  Band.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

struct Band: Codable {
    let creator: User
    let members: [User]
    let genre: Genre
    let links: [Link]?
    let shows: [Show]?
    let city: String
    let state: String
    
    static let example = Band(
        creator: User.example,
        members: [User.example],
        genre: .rock,
        links: nil,
        shows: nil,
        city: "Neptune",
        state: "New Jersey"
    )
}
