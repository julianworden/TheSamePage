//
//  BassGuitarGear.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/4/23.
//

import Foundation

enum BassGuitarGear: String, CaseIterable, Identifiable {
    case ampHead = "Bass Guitar Amp Head"
    case cab = "Bass Guitar Cab"
    case comboAmp = "Bass Guitar Combo Amp"

    var id: Self { self }
}
