//
//  BacklineGearType.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import Foundation

enum BacklineItemType: String, CaseIterable, Identifiable{
    case percussion = "Percussion"
    case electricGuitar = "Electric Guitar"
    case bassGuitar = "Bass Guitar"
    case acousticGuitar = "Acoustic Guitar"
    case keys = "Keys"
    case stageGear = "Stage Gear"
    
    var id: Self { self }
}
