//
//  BandIdOnly.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import FirebaseFirestoreSwift
import Foundation

struct JoinedBand: Codable, Equatable, Hashable, Identifiable {
    @DocumentID var id: String?
}
