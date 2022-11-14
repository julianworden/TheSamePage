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
    let id: String
    let name: String
    let bio: String?
    let profileImageUrl: String?
    let adminUid: String
    let memberUids: [String]
    let memberFcmTokens: [String]
    let genre: String
    let city: String
    let state: String
    
    init(
        id: String,
        name: String,
        bio: String? = nil,
        profileImageUrl: String? = nil,
        adminUid: String,
        memberUids: [String] = [],
        memberFcmTokens: [String] = [],
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
        self.memberFcmTokens = memberFcmTokens
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
    
    var loggedInUserIsNotInvolvedWithBand: Bool {
        return !loggedInUserIsBandAdmin && !loggedInUserIsBandMember
    }
    
    var loggedInUserIsInvolvedWithBand: Bool {
        return loggedInUserIsBandAdmin || loggedInUserIsBandMember
    }
    
    static let example = Band(
        id: "a;efhalskehasf",
        name: "Pathetic Fallacy",
        bio: "A bangin metalcore band from New Jersey. We will slay all the shows. ALL OF THEM!!! Nobody will be spared, not even your mom.",
        adminUid: "sdfadgasergawergae",
        memberFcmTokens: ["a;woiefajwef"],
        genre: Genre.rock.rawValue,
        city: "Neptune",
        state: "NJ"
    )
}
