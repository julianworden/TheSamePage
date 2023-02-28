//
//  DrumKitBacklineItem.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/20/22.
//

import FirebaseFirestoreSwift
import Foundation

struct DrumKitBacklineItem: Backline, Codable, Equatable, Identifiable {
    @DocumentID var id: String?
    /// The UID for the user that added this item to a show's backline
    let backlinerUid: String
    /// The first and last name of the user that added this item to a show's backline
    let backlinerFullName: String
    let backlinerUsername: String
    let type: String
    let name: String
    let notes: String?
    let includedKitPieces: [String]
    
    var includedKitPiecesFormattedList: String {
        let listFormatter = ListFormatter()
        return listFormatter.string(from: includedKitPieces) ?? ""
    }

    var loggedInUserIsBackliner: Bool {
        return backlinerUid == AuthController.getLoggedInUid()
    }

    init(
        id: String? = nil,
        backlinerUid: String,
        backlinerFullName: String,
        backlinerUsername: String,
        type: String,
        name: String,
        notes: String? = nil,
        includedKitPieces: [String] = []
    ) {
        self.id = id
        self.backlinerUid = backlinerUid
        self.backlinerFullName = backlinerFullName
        self.backlinerUsername = backlinerUsername
        self.type = type
        self.name = name
        self.notes = notes
        self.includedKitPieces = includedKitPieces
    }
}
