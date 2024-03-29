//
//  User.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct User: Codable, Equatable, Hashable, Identifiable, Shareable {
    var id: String
    let name: String
    let firstName: String
    let lastName: String
    var profileImageUrl: String?
    let phoneNumber: String?
    let emailAddress: String
    let fcmToken: String?

    /// A convenience property that makes it easier to determine if a user search result belongs to the logged in user.
    var isLoggedInUser: Bool {
        return id == AuthController.getLoggedInUid()
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    init(
        id: String,
        name: String,
        firstName: String,
        lastName: String,
        profileImageUrl: String? = nil,
        phoneNumber: String? = nil,
        emailAddress: String,
        fcmToken: String? = nil
    ) {
        self.id = id
        self.name = name
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageUrl = profileImageUrl
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.fcmToken = fcmToken
    }
    
    static let example = User(
        id: "alisuhefawuilfn",
        name: "julianworden",
        firstName: "Julian",
        lastName: "Worden",
        profileImageUrl: nil,
        phoneNumber: nil,
        emailAddress: "julianworden@gmail.com"
    )
}
