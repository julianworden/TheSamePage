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
    /// The UID for the user that added this item to a show's backline
    let backlinerUid: String
    /// The first and last name of the user that added this item to a show's backline
    let backlinerFullName: String
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

    init(
        id: String? = nil,
        backlinerUid: String,
        backlinerFullName: String,
        type: String,
        name: String,
        notes: String? = nil,
        kickIncluded: Bool,
        snareIncluded: Bool,
        tomsIncluded: Bool,
        numberOfTomsIncluded: Int? = nil,
        hiHatIncluded: Bool,
        cymbalsIncluded: Bool,
        numberOfCymbalsIncluded: Int? = nil,
        cymbalStandsIncluded: Bool,
        numberOfCymbalStandsIncluded: Int? = nil
    ) {
        self.id = id
        self.backlinerUid = backlinerUid
        self.backlinerFullName = backlinerFullName
        self.type = type
        self.name = name
        self.notes = notes
        self.kickIncluded = kickIncluded
        self.snareIncluded = snareIncluded
        self.tomsIncluded = tomsIncluded
        self.numberOfTomsIncluded = numberOfTomsIncluded
        self.hiHatIncluded = hiHatIncluded
        self.cymbalsIncluded = cymbalsIncluded
        self.numberOfCymbalsIncluded = numberOfCymbalsIncluded
        self.cymbalStandsIncluded = cymbalStandsIncluded
        self.numberOfCymbalStandsIncluded = numberOfCymbalStandsIncluded
    }
}
