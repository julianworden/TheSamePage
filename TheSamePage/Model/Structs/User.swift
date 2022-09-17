//
//  User.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

struct User: Codable {
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
                id: UUID(),
                name: "Pathetic Fallacy ROCKS!",
                admin: "",
                members: [],
                genre: Genre.rock.rawValue,
                links: nil,
                shows: nil,
                city: "Neptune",
                state: "NJ"
            ),
            Band(
                id: UUID(),
                name: "Dumpweed",
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
