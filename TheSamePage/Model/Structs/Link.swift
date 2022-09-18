//
//  Link.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestoreSwift
import Foundation

struct Link: Codable {
    @DocumentID var id: String?
    let platformName: String
    let url: String
}
