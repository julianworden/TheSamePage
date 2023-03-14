//
//  PlatformLink.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestoreSwift
import Foundation

struct PlatformLink: Codable, Equatable, Hashable, Identifiable {
    @DocumentID var id: String?
    let platformName: String
    let url: String

    var platformNameAsPlatformLinkObject: LinkPlatform {
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
