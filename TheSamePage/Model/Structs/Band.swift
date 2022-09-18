//
//  Band.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct Band: Codable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var dateCreated: Timestamp?
    let name: String
    let admin: String
    let members: [String]
    let genre: String
    let links: [Link]?
    let shows: [Show]?
    let city: String
    let state: String
    
    static let example = Band(
        name: "Pathetic Fallacy",
        admin: "",
        members: [],
        genre: Genre.rock.rawValue,
        links: nil,
        shows: nil,
        city: "Neptune",
        state: "NJ"
    )
}
