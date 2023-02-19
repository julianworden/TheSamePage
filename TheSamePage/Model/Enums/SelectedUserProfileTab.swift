//
//  SelectedUserProfileTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/18/23.
//

import Foundation

enum SelectedUserProfileTab: String, CaseIterable, Identifiable {
    case bands = "Bands"
    case shows = "Shows"

    var id: Self { self }
}
