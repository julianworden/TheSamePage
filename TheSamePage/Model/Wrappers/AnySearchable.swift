//
//  AnySearchable.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/27/22.
//

import Foundation

/// A wrapper for the Searchable protocol that allows it to conform to the Identifiable protocol.
struct AnySearchable: Equatable, Identifiable {
    var id: String
    var searchable: any Searchable
    
    static func == (lhs: AnySearchable, rhs: AnySearchable) -> Bool {
        lhs.id == rhs.id && lhs.searchable.name == rhs.searchable.name
    }
}
