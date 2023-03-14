//
//  KeysGearType.swift
//  TheSamePage
//
//  Created by Julian Worden on 3/12/23.
//

import Foundation

enum KeysGearType: String, CaseIterable, Identifiable {
    case keyboard = "Keyboard"
    case piano = "Piano"
    case keyboardStand = "Keyboard Stand"
    case keyboardAmp = "Keyboard Amp"
    case sustainPedal = "Keyboard Sustain Pedal"

    var id: Self { self }
}
