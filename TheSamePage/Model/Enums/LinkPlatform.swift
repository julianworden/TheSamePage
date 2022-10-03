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
    case appleMusic = "Apple Music"
    // For satisfying exhaustive enum requirements
    case none
    
    var id: Self { self }
    
    var urlPrefix: String {
        switch self {
        case .instagram:
            return "instagram://user?username="
        case .facebook:
            return "https://en-gb.facebook.com/"
        case .appleMusic, .spotify, .none:
            return ""
        }
    }
}
