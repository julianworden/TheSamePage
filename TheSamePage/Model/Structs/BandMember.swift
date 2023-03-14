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
    let id: String
    let dateJoined: Double
    let uid: String
    let role: String
    let username: String
    let fullName: String

    var dateJoinedUnixDateAsDate: Date {
        return Date(timeIntervalSince1970: dateJoined)
    }
    
    var bandMemberIsLoggedInUser: Bool {
        return AuthController.getLoggedInUid() == uid
    }

    /// Returned value matches the name of the asset in the assets catalog that provides an image
    /// of the user's role in the band.
    var listRowIconName: String {
        return role.lowercased()
    }
    
    static let example = BandMember(
        id: "a;osiejfa;wefj",
        dateJoined: 3412341,
        uid: "as;ldkfajs;dlfkja",
        role: "Guitar",
        username: "Lousabba",
        fullName: "Lou Sabba"
    )
}
