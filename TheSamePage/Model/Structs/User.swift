//
//  User.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct User: Codable, Equatable, Hashable, Identifiable {
    var id: String?
    let username: String
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
    let phoneNumber: String?
    let emailAddress: String
    
    init(
        id: String? = nil,
        username: String,
        firstName: String,
        lastName: String,
        profileImageUrl: String? = nil,
        phoneNumber: String? = nil,
        emailAddress: String
    ) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageUrl = profileImageUrl
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
    }
    
    static let example = User(
        username: "julianworden",
        firstName: "Julian",
        lastName: "Worden",
        profileImageUrl: nil,
        phoneNumber: nil,
        emailAddress: "julianworden@gmail.com"
    )
}
