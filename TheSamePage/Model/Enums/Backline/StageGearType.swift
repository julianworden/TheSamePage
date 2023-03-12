//
//  StageGearType.swift
//  TheSamePage
//
//  Created by Julian Worden on 3/12/23.
//

import Foundation

enum StageGearType: String, CaseIterable, Identifiable {
    case microphone = "Microphone"
    case diBox = "DI Box"
    case stageBox = "Stage Box / Snake"
    case pa = "PA"

    var id: Self { self }
}
