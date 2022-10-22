//
//  VocalGear.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import Foundation

enum VocalGear: String, CaseIterable, Identifiable {
    case microphone = "Microphone"
    case pa = "PA"
    
    var id: Self { self }
}
