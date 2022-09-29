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
struct BandMember: Codable, Equatable, Identifiable {
    @DocumentID var id: String?
    @ServerTimestamp var dateJoined: Timestamp?
    let uid: String
    let role: String
    let name: String
    
    static let example = BandMember(
        uid: "as;ldkfajs;dlfkja",
        role: "Guitar",
        name: "Lou Sabba"
    )
}
