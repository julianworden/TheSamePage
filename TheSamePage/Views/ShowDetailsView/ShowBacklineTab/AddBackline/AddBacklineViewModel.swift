//
//  AddBacklineViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import Foundation
import SwiftUI

class AddBacklineViewModel: ObservableObject {
    @Published var selectedGearType = BacklineItemType.electricGuitar
    @Published var selectedGuitarGear = GuitarGear.comboAmp
    @Published var selectedPercussionGearType = PercussionGearType.fullKit
    @Published var selectedDrumKitPiece = DrumKitPiece.kick
    @Published var selectedAuxillaryPercussion = AuxillaryPercussion.congas
    @Published var backlineGearNotes = ""
    
    @Published var kickIncluded = false
    @Published var snareIncluded = false
    @Published var tomsIncluded = false
    @Published var numberOfTomsIncluded = 0
    @Published var hiHatIncluded = false
    @Published var cymbalsIncluded = false
    @Published var numberOfCymbalsIncluded = 0
    @Published var cymbalStandsIncluded = false
    @Published var numberOfCymbalStandsIncluded = 0
    
    let show: Show
    
    init(show: Show) {
        self.show = show
    }
    
    func addBacklineItemToShow() throws {
        var backlineItem: BacklineItem?
        var drumKitBacklineItem: DrumKitBacklineItem?
        
        switch selectedGearType {
        case .electricGuitar, .bassGuitar:
            backlineItem = BacklineItem(
                type: selectedGearType.rawValue,
                name: selectedGuitarGear.rawValue,
                notes: backlineGearNotes
            )
        case .percussion:
            if selectedPercussionGearType == .fullKit {
                drumKitBacklineItem = DrumKitBacklineItem(
                    type: selectedGearType.rawValue,
                    name: selectedPercussionGearType.rawValue,
                    notes: backlineGearNotes,
                    kickIncluded: kickIncluded,
                    snareIncluded: snareIncluded,
                    tomsIncluded: tomsIncluded,
                    numberOfTomsIncluded: numberOfTomsIncluded,
                    hiHatIncluded: hiHatIncluded,
                    cymbalsIncluded: cymbalsIncluded,
                    numberOfCymbalsIncluded: numberOfCymbalsIncluded,
                    cymbalStandsIncluded: cymbalStandsIncluded,
                    numberOfCymbalStandsIncluded: numberOfCymbalStandsIncluded
                )
            } else {
                backlineItem = BacklineItem(
                    type: selectedGearType.rawValue,
                    name: selectedAuxillaryPercussion.rawValue,
                    notes: backlineGearNotes
                )
            }
        }
        
        try DatabaseService.shared.addBacklineItemToShow(
            backlineItem: backlineItem,
            drumKitBacklineItem: drumKitBacklineItem,
            show: show
        )
    }
    
    func incrementNumberOfTomsIncluded() {
        numberOfTomsIncluded += 1
    }
    
    func decrementNumberOfTomsIncluded() {
        numberOfTomsIncluded -= 1
    }
    
    func incrementNumberOfCymbalsIncluded() {
        numberOfCymbalsIncluded += 1
    }
    
    func decrementNumberOfCymbalsIncluded() {
        if numberOfCymbalsIncluded >= 1 {
            numberOfCymbalsIncluded -= 1
        }
    }
    
    func incrementNumberOfCymbalStandsIncluded() {
        numberOfCymbalStandsIncluded += 1
    }
    
    func decrementNumberOfCymbalStandsIncluded() {
        numberOfCymbalStandsIncluded -= 1
    }
}
