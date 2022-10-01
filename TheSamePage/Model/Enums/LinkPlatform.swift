//
//  LinkPlatform.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import Foundation

enum LinkPlatform: String, CaseIterable, Identifiable {
    case spotify = "Spotify"
    case instagram = "Instagram"
    case facebook = "Facebook"
    // For satisfying exhaustive enum requirements
    case none
    
    var id: Self { self }
    
    var urlPrefix: String {
        switch self {
        case .spotify:
            return ""
        case .instagram:
            return "instagram://user?username="
        case .facebook:
            return "https://facebook.com/"
        case .none:
            return ""
        }
    }
}
