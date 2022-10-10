//
//  ShowDetailsTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import Foundation

enum SelectedShowDetailsTab: String, CaseIterable, Identifiable {
    case lineup = "Lineup"
    case backline = "Backline"
    case times = "Times"
    case location = "Location"
    case details = "Details"
    
    var id: Self { self }
}
