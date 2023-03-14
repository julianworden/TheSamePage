//
//  GuitarGear.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import Foundation

/// Backline options for both electric and bass guitar gear.
enum ElectricGuitarGear: String, CaseIterable, Identifiable {
    case ampHead = "Electric Electric Amp Head"
    case cab = "Electric Guitar Cab"
    case comboAmp = "Electric Guitar Combo Amp"

    var id: Self { self }
}
