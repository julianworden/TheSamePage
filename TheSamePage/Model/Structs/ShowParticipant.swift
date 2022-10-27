//
//  ShowParticipant.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/6/22.
//

import FirebaseFirestoreSwift
import Foundation

/// A helper type that allows for the storage of only the most essential information
/// in a Show's participants collection. This data is used for displaying lineup info
/// in ShowDetailsView.
struct ShowParticipant: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let bandId: String
    let showId: String
    
    static let example = ShowParticipant(
        name: "Pathetic Fallacy",
        bandId: "a;lsdkjfa;sldf",
        showId: ";alskdfj;aslkf"
    )
}
