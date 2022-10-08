//
//  BandMember.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

/// The object passed into a band's members collection. Created to avoid adding a User object with unnecessary data
/// to every band's members collection.
struct BandMember: Codable, Equatable, Hashable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var dateJoined: Timestamp?
    let uid: String
    let role: String
    let username: String
    let fullName: String
    
    var bandMemberIsLoggedInUser: Bool {
        return AuthController.getLoggedInUid() == uid
    }
    
    var listRowIconName: String {
        return role.lowercased()
    }
    
    static let example = BandMember(
        uid: "as;ldkfajs;dlfkja",
        role: "Guitar",
        username: "Lousabba",
        fullName: "Lou Sabba"
    )
}
