//
//  GuitarGear.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import Foundation

/// Backline options for both electric and bass guitar gear.
enum GuitarGear: String, CaseIterable, Identifiable {
    case ampHead = "Amp Head"
    case cab = "Cab"
    case comboAmp = "Combo Amp"
    
    var id: Self { self }
}
