//
//  LinkPlatform.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import Foundation

enum LinkPlatform: String, CaseIterable, Identifiable {
    case spotify = "Spotify"
    case appleMusic = "Apple Music"
    case soundcloud = "SoundCloud"
    case bandcamp = "Bandcamp"
    case instagram = "Instagram"
    case tiktok = "TikTok"
    case twitter = "Twitter"
    case snapchat = "Snapchat"
    case facebook = "Facebook"
    // For satisfying exhaustive enum requirements
    case none
    
    var id: Self { self }

    #warning("Add icons for bandcamp, twitter, and snapchat once icons8 works.")
}
