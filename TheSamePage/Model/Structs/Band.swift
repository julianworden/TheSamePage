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
    
    var loggedInUserIsBandAdmin: Bool {
        return adminUid == AuthController.getLoggedInUid()
    }
    
    static let example = Band(
        name: "Pathetic Fallacy",
        bio: "A bangin metalcore band from New Jersey. We will slay all the shows. ALL OF THEM!!! Nobody will be spared, not even your mom.",
        profileImageUrl: nil,
        adminUid: "",
        memberUids: [],
        genre: Genre.rock.rawValue,
        city: "Neptune",
        state: "NJ"
    )
}
