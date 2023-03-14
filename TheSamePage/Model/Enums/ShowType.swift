//
//  ShowType.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/9/22.
//

import Foundation

enum ShowType: String, CaseIterable, Identifiable {
    case hosting = "Hosting"
    case playing = "Playing"
    
    var id: Self { self }
}
