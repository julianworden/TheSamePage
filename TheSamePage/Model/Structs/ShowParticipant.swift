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
    let bandAdminUid: String
    let showId: String
    let setTime: Double?

    init(
        id: String? = nil,
        name: String,
        bandId: String,
        bandAdminUid: String,
        showId: String,
        setTime: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.bandId = bandId
        self.bandAdminUid = bandAdminUid
        self.showId = showId
        self.setTime = setTime
    }
    
    static let example = ShowParticipant(
        name: "Pathetic Fallacy",
        bandId: "a;lsdkjfa;sldf",
        bandAdminUid: "alskhfawoiefhawio",
        showId: ";alskdfj;aslkf"
    )

    var bandAdminIsLoggedInUser: Bool {
        return AuthController.getLoggedInUid() == bandAdminUid
    }
}
