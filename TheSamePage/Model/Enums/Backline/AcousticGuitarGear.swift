//
//  AcousticGuitarGear.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/4/23.
//

import Foundation

enum AcousticGuitarGear: String, CaseIterable, Identifiable {
    case amp = "Acoustic Guitar Amp"

    var id: Self { self }
}
