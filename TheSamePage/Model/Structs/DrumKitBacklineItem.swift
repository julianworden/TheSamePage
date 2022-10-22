//
//  DrumKitBacklineItem.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/20/22.
//

import FirebaseFirestoreSwift
import Foundation

struct DrumKitBacklineItem: Codable, Identifiable {
    @DocumentID var id: String?
    let type: String
    let name: String
    let notes: String?
    let kickIncluded: Bool
    let snareIncluded: Bool
    let tomsIncluded: Bool
    let numberOfTomsIncluded: Int?
    let hiHatIncluded: Bool
    let cymbalsIncluded: Bool
    let numberOfCymbalsIncluded: Int?
    let cymbalStandsIncluded: Bool
    let numberOfCymbalStandsIncluded: Int?
    
    var details: String {
        return "\(kickIncluded ? "Kick" : ""), \(snareIncluded ? "Snare" : ""), \(tomsIncluded ? "\(numberOfTomsIncluded ?? 2) toms" : ""), \(hiHatIncluded ? "Hi-Hat" : ""), \(cymbalsIncluded ? "\(numberOfCymbalsIncluded ?? 2) cymbals" : ""), \(cymbalStandsIncluded ? "\(numberOfCymbalStandsIncluded ?? 2) cymbal stands" : "")"
    }
}
