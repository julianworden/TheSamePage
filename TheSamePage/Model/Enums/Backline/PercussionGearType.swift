//
//  DrumGear.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import Foundation

enum PercussionGearType: String, CaseIterable, Identifiable {
    case kitPiece = "Kit Piece"
    case fullKit = "Full Kit"
    case auxiliaryPercussion = "Auxiliary Percussion"
    case miscellaneous = "Miscellaneous"
    
    var id: Self { self }
}

enum DrumKitPiece: String, CaseIterable, Identifiable {
    case kick = "Kick"
    case kickPedal = "Kick Pedal"
    case snare = "Snare"
    case tom = "Tom"
    case hiHat = "Hi-Hat"
    case rideCymbal = "Ride Cymbal"
    case crashCymbal = "Crash Cymbal"
    case chinaCymbal = "China Cymbal"
    case cymbal = "Cymbal"
    
    var id: Self { self }
}

enum MiscellaneousPercussionGear: String, CaseIterable, Identifiable {
    case rug = "Rug"
    case throne = "Throne"
    case hiHatClutch = "Hi-Hat Clutch"

    var id: Self { self }
}
