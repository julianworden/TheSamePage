//
//  DrumGear.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import Foundation

enum PercussionGearType: String, CaseIterable, Identifiable {
    case fullKit = "Full Kit"
    case kitPiece = "Kit Piece"
    case auxillaryPercussion = "Aux. Percussion"
    
    var id: Self { self }
}

enum DrumKitPiece: String, CaseIterable, Identifiable {
    case kick = "Kick"
    case kickPedal = "Kick Pedal"
    case snare = "Snare"
    case tom = "Tom"
    case chinaCymbal = "China Cymbal"
    case crashCymbal = "Crash Cymbal"
    case hiHat = "Hi-Hat"
    
    var id: Self { self }
}

enum AuxillaryPercussion: String, CaseIterable, Identifiable {
    case congas = "Congas"
    
    var id: Self { self }
}
