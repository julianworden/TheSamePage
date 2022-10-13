//
//  ShowTimeType.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import Foundation

enum ShowTimeType: String, CaseIterable, Identifiable {
    case loadIn = "Load In"
    case musicStart = "Music Start"
    case end = "End"
    case doors = "Doors"
    
    var id: Self { self }
}
