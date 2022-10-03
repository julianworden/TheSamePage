//
//  PlatformLink.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestoreSwift
import Foundation

struct PlatformLink: Codable, Equatable, Hashable, Identifiable {
    enum LinkError: Error {
        case invalidPlatformName(message: String)
    }
    
    @DocumentID var id: String?
    let platformName: String
    let url: String
    // For satisfying exhaustive enum requirements
    
    var platformNameAsLinkPlatformObject: LinkPlatform {
        switch platformName {
        case "Spotify":
            return .spotify
        case "Instagram":
            return .instagram
        case "Facebook":
            return .facebook
        default:
            return .none
        }
    }
    
    static let example = PlatformLink(
        platformName: "spotify",
        url: "asdfasdf"
    )
}
