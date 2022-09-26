//
//  Instrument.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/25/22.
//

import Foundation

enum Instrument: String, CaseIterable, Identifiable {
    var id: Self { self }
    case bassGuitar = "Bass Guitar"
    case guitar = "Guitar"
    case vocals = "Vocals"
    case drums = "Drums"
    case keys = "Keys"
}
