//
//  AnySearchable.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/27/22.
//

import Foundation

struct AnySearchable: Equatable, Identifiable {
    var id: String
    var searchable: any Searchable
    
    static func == (lhs: AnySearchable, rhs: AnySearchable) -> Bool {
        lhs.id == rhs.id && lhs.searchable.name == rhs.searchable.name
    }
}
