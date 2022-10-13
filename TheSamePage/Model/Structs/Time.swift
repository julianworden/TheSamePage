//
//  Time.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct Time: Codable, Equatable, Hashable, Identifiable {
    @DocumentID var id: String?
    let type: String
    let time: Double
//    let loadIn: Double?
//    let doors: Double?
//    let musicStart: Double?
//    let end: Double?
    
    static let example = Time(
        type: ShowTimeType.doors.rawValue,
        time: 4637586987
    )
}
