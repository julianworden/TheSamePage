//
//  Backline.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

struct Backline: Codable {
    let hasDrums: Bool
    let drumsOwner: User?
    let hasGuitarAmp: Bool
    let guiarAmpOwner: User?
    let hasGuitarCab: Bool
    let guitarCabOwner: User?
    let hasBassAmp: Bool
    let bassAmpOwner: User?
    let hasBassCab: Bool
    let bassCabOwner: User?
    let hasPa: Bool
    let paOwner: User?
}
