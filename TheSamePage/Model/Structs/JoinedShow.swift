//
//  JoinedShow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import FirebaseFirestoreSwift
import Foundation

/// An object in either a band's or user's joinedShows collection
struct JoinedShow: Identifiable {
    @DocumentID var id: String?
}
