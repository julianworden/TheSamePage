//
//  Genre.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

enum Genre: String, Codable, Equatable, Identifiable, CaseIterable {
    var id: Self { self }
    case alternative = "Alternative"
    case ambient = "Ambient"
    case bluegrass = "Bluegrass"
    case blues = "Blues"
    case classical = "Classical"
    case country = "Country"
    case deathcore = "Deathcore"
    case deathMetal = "Death Metal"
    case dubstep = "Dubstep"
    case easyListening = "Easy Listening"
    case edm = "EDM"
    case electronic = "Electronic"
    case experimental = "Experimental"
    case folk = "Folk"
    case funk = "Funk"
    case gospel = "Gospel"
    case grunge = "Grunge"
    case hardcore = "Hardcore"
    case hipHop = "Hip-Hop"
    case indie = "Indie"
    case industrial = "Industrial"
    case jazz = "Jazz"
    case latin = "Latin"
    case metal = "Metal"
    case metalcore = "Metalcore"
    case pop = "Pop"
    case progressiveRock = "Progressive Rock"
    case punk = "Punk"
    case rap = "Rap"
    case reggae = "Reggae"
    case rock = "Rock"
    case rnb = "RnB"
    case ska = "Ska"
    case soul = "Soul"
    case techno = "Techno"
    case trap = "Trap"
    case various = "Various"
    case world = "World"
}
