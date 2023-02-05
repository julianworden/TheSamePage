//
//  BacklineItem.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestoreSwift
import Foundation

struct BacklineItem: Backline, Codable, Equatable, Hashable, Identifiable {
    @DocumentID var id: String?
    /// The UID for the user that added this item to a show's backline
    let backlinerUid: String
    /// The first and last name of the user that added this item to a show's backline
    let backlinerFullName: String
    let type: String
    let name: String
    let notes: String?

    var loggedInUserIsBackliner: Bool {
        return backlinerUid == AuthController.getLoggedInUid()
    }
    
    init(
        id: String? = nil,
        backlinerUid: String,
        backlinerFullName: String,
        type: String,
        name: String,
        notes: String? = nil
    ) {
        self.id = id
        self.backlinerUid = backlinerUid
        self.backlinerFullName = backlinerFullName
        self.type = type
        self.name = name
        self.notes = notes
    }
}
