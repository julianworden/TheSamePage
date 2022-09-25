//
//  Genre.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

enum Genre: String, Codable, Identifiable, CaseIterable {
    var id: Self { self }
    case alternative = "Alternative"
    case edm = "EDM"
    case hipHop = "Hip-Hop"
    case pop = "Pop"
    case rap = "Rap"
    case trap = "Trap"
    case rock = "Rock"
    case metal = "Metal"
    case metalcore = "Metalcore"
    case deathcore = "Deathcore"
    case deathMetal = "Death Metal"
    case various = "Various"
}
