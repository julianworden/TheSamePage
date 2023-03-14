//
//  SearchType.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/26/22.
//

import Foundation

enum SearchType: String, CaseIterable, Identifiable {
    case user = "User"
    case band = "Band"
    case show = "Show"
    
    var id: Self { self }
    
    var firestoreCollection: String {
        switch self {
        case .user:
            return "users"
        case .band:
            return "bands"
        case .show:
            return "shows"
        }
    }
}
