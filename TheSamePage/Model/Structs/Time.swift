//
//  Time.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct Time: Codable {
    @DocumentID var id: String?
    let loadIn: Timestamp?
    let doors: Timestamp?
    let firstSetStart: Timestamp?
    let end: Timestamp?
    
    static let example = Time(
        loadIn: Timestamp(date: Date()),
        doors: Timestamp(date: Date()),
        firstSetStart: Timestamp(date: Date()),
        end: Timestamp(date: Date())
    )
}
