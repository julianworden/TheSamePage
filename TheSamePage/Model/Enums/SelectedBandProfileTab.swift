//
//  SelectedBandProfileTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import Foundation

enum SelectedBandProfileTab: String, CaseIterable, Identifiable {
    case about = "About"
    case members = "Members"
    case links = "Links"
    case shows = "Shows"
    
    var id: Self { self }
}
