//
//  Time.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

struct Time: Codable {
    // TODO: Replace Date types with Timestamp Firebase types
    let loadIn: Date
    let loadOut: Date
    let start: Date
    let end: Date
    
    static let example = Time(
        loadIn: Date(),
        loadOut: Date(),
        start: Date(),
        end: Date()
    )
}
