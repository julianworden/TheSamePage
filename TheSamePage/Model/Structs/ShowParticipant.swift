//
//  ShowParticipant.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/6/22.
//

import FirebaseFirestoreSwift
import Foundation

// TODO: Add info to this
struct ShowParticipant: Codable, Identifiable {
    @DocumentID var id: String?
}
