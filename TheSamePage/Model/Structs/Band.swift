//
//  Band.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct Band: Codable, Equatable, Identifiable, Searchable {
    @DocumentID var id: String?
    @ServerTimestamp var dateCreated: Timestamp?
    let name: String
    let bio: String?
    let profileImageUrl: String?
    let adminUid: String
    let members: [BandMember]?
    let genre: String
    // TODO: Links
    let links: [Link]?
    let shows: [Show]?
    let city: String
    let state: String
    
    static let example = Band(
        name: "Pathetic Fallacy",
        bio: "A bangin metalcore band from New Jersey. We will slay all the shows. ALL OF THEM!!! Nobody will be spared, not even your mom.",
        profileImageUrl: nil,
        adminUid: "",
        members: [],
        genre: Genre.rock.rawValue,
        links: nil,
        shows: nil,
        city: "Neptune",
        state: "NJ"
    )
}
