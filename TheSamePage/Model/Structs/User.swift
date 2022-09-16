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
        bands: []
    )
}
