//
//  User.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var dateCreated: Timestamp?
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
    let phoneNumber: String?
    let emailAddress: String
    let bandInvites: [BandInvite]?
    let joinedBands: [JoinedBand]?
    
    static let example = User(
        firstName: "Julian",
        lastName: "Worden",
        profileImageUrl: nil,
        phoneNumber: nil,
        emailAddress: "julianworden@gmail.com",
        bandInvites: nil,
        joinedBands: nil
    )
}
