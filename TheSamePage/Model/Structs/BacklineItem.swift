//
//  BacklineItem.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestoreSwift
import Foundation

struct BacklineItem: Codable, Equatable, Hashable, Identifiable {
    @DocumentID var id: String?
    let type: String
    let name: String
    let notes: String?
    
    init(
        id: String? = nil,
        type: String,
        name: String,
        notes: String? = nil
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.notes = notes
    }
}
