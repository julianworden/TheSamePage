//
//  BandIdOnly.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import Foundation

/// An object used with a user's bandIds Firestore collection. This is to make up for the fact that
/// making empty documents in Firestore is not possible.
struct BandId: Codable {
    let id: String
}
