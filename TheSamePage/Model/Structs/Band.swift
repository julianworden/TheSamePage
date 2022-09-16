//
//  Band.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

struct Band: Codable {
    let members: [User]
    let genre: Genre
    let links: [Link]?
    let shows: [Show]?
    
    static let example = Band(
        members: [User.example],
        genre: .rock,
        links: nil,
        shows: nil
    )
}
