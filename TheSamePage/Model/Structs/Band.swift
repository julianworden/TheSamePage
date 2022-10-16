//
//  Band.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct Band: Codable, Equatable, Hashable, Identifiable {
    var id: String?
    let name: String
    let bio: String?
    let profileImageUrl: String?
    let adminUid: String
    let memberUids: [String]
    let genre: String
    let city: String
    let state: String
    
    init(
        id: String? = nil,
        name: String,
        bio: String? = nil,
        profileImageUrl: String? = nil,
        adminUid: String,
        memberUids: [String] = [],
        genre: String,
        city: String,
        state: String
    ) {
        self.id = id
        self.name = name
        self.bio = bio
        self.profileImageUrl = profileImageUrl
        self.adminUid = adminUid
        self.memberUids = memberUids
        self.genre = genre
        self.city = city
        self.state = state
    }
    
    var loggedInUserIsBandAdmin: Bool {
        return adminUid == AuthController.getLoggedInUid()
    }
    
    var loggedInUserIsBandMember: Bool {
        return memberUids.contains(AuthController.getLoggedInUid())
    }
    
    static let example = Band(
        name: "Pathetic Fallacy",
        bio: "A bangin metalcore band from New Jersey. We will slay all the shows. ALL OF THEM!!! Nobody will be spared, not even your mom.",
        adminUid: "sdfadgasergawergae",
        genre: Genre.rock.rawValue,
        city: "Neptune",
        state: "NJ"
    )
}
