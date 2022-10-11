//
//  JoinedShow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import FirebaseFirestoreSwift
import Foundation

// TODO: Get rid of this type
/// An object in either a band's or user's joinedShows collection
struct JoinedShow: Codable, Identifiable {
    @DocumentID var id: String?
    let showId: String
    let name: String
    let date: String
    let venue: String
    let hasFood: Bool
    let hasBar: Bool
    let is21Plus: Bool
    var description: String?
}
