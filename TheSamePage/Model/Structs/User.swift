//
//  User.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct User: Codable {
    @DocumentID var id: String?
    @ServerTimestamp var dateCreated: Timestamp?
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
    let phoneNumber: String?
    let emailAddress: String?
    let bands: [Band]?
    
    static let example = User(
        firstName: "Julian",
        lastName: "Worden",
        profileImageUrl: nil,
        phoneNumber: nil,
        emailAddress: nil,
        bands: [
            Band(
                name: "Pathetic Fallacy",
                profileImageUrl: nil,
                admin: "",
                members: [],
                genre: Genre.rock.rawValue,
                links: nil,
                shows: nil,
                city: "Neptune",
                state: "NJ"
            ),
            Band(
                name: "Dumpweed",
                profileImageUrl: nil,
                admin: "",
                members: [],
                genre: Genre.rock.rawValue,
                links: nil,
                shows: nil,
                city: "South Brunswick",
                state: "NJ"
            )
        ]
    )
}
