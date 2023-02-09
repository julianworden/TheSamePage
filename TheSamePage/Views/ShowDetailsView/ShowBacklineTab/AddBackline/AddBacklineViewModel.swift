//
//  AddBacklineViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import Foundation
import SwiftUI

@MainActor
final class AddBacklineViewModel: ObservableObject {
    @Published var selectedGearType = BacklineItemType.electricGuitar
    @Published var selectedPercussionGearType = PercussionGearType.fullKit
    @Published var selectedElectricGuitarGear = ElectricGuitarGear.comboAmp
    @Published var selectedBassGuitarGear = BassGuitarGear.comboAmp
    @Published var selectedAcousticGuitarGear = AcousticGuitarGear.amp
    @Published var selectedDrumKitPiece = DrumKitPiece.kick
    @Published var selectedAuxillaryPercussion = AuxillaryPercussion.congas
    @Published var backlineGearNotes = ""
    
    @Published var kickIncluded = false
    @Published var snareIncluded = false
    @Published var tomsIncluded = false
    @Published var numberOfTomsIncluded = 1
    @Published var hiHatIncluded = false
    @Published var cymbalsIncluded = false
    @Published var numberOfCymbalsIncluded = 1
    @Published var cymbalStandsIncluded = false
    @Published var numberOfCymbalStandsIncluded = 1
    var includedKitPieces = [String]()
    
    @Published var buttonsAreDisabled = false
    @Published var gearAddedSuccessfully = false

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    let show: Show

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                gearAddedSuccessfully = true
                buttonsAreDisabled = false
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }

    var newBacklineItemName: String {
        switch selectedGearType {
        case .electricGuitar:
            return selectedElectricGuitarGear.rawValue
        case .bassGuitar:
            return selectedBassGuitarGear.rawValue
        case .acousticGuitar:
            return selectedAcousticGuitarGear.rawValue
        default:
            return "Invalid Backline Item Name"
        }
    }

    init(show: Show) {
        self.show = show
    }

    func createIncludedKitPiecesArray() {
        if kickIncluded {
            includedKitPieces.append("Kick")
        }

        if snareIncluded {
            includedKitPieces.append("Snare")
        }

        if tomsIncluded {
            includedKitPieces.append("\(numberOfTomsIncluded) \(numberOfTomsIncluded == 1 ? "Tom" : "Toms")")
        }

        if hiHatIncluded {
            includedKitPieces.append("Hi-Hat")
        }

        if cymbalsIncluded {
            includedKitPieces.append("\(numberOfCymbalsIncluded) \(numberOfCymbalsIncluded == 1 ? "Cymbal" : "Cymbals")")
        }

        if cymbalStandsIncluded {
            includedKitPieces.append("\(numberOfCymbalStandsIncluded) \(numberOfCymbalStandsIncluded == 1 ? "Cymbal Stand" : "Cymbal Stands")")
        }
    }

    @discardableResult func addBacklineItemToShow() async -> String {
        do {
            viewState = .performingWork

            let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
            var backlineItem: BacklineItem?
            var drumKitBacklineItem: DrumKitBacklineItem?

            switch selectedGearType {
            case .electricGuitar, .bassGuitar, .acousticGuitar:
                backlineItem = BacklineItem(
                    backlinerUid: loggedInUser.id,
                    backlinerFullName: loggedInUser.fullName,
                    type: selectedGearType.rawValue,
                    name: newBacklineItemName,
                    notes: backlineGearNotes.isReallyEmpty ? nil : backlineGearNotes
                )

            case .percussion:
                switch selectedPercussionGearType {
                case .fullKit:
                    createIncludedKitPiecesArray()

                    drumKitBacklineItem = DrumKitBacklineItem(
                        backlinerUid: loggedInUser.id,
                        backlinerFullName: loggedInUser.fullName,
                        type: selectedGearType.rawValue,
                        name: selectedPercussionGearType.rawValue,
                        notes: backlineGearNotes.isReallyEmpty ? nil : backlineGearNotes,
                        includedKitPieces: includedKitPieces
                    )

                case .kitPiece:
                    backlineItem = BacklineItem(
                        backlinerUid: loggedInUser.id,
                        backlinerFullName: loggedInUser.fullName,
                        type: selectedGearType.rawValue,
                        name: selectedDrumKitPiece.rawValue,
                        notes: backlineGearNotes.isReallyEmpty ? nil : backlineGearNotes
                    )

                case .auxillaryPercussion:
                    backlineItem = BacklineItem(
                        backlinerUid: loggedInUser.id,
                        backlinerFullName: loggedInUser.fullName,
                        type: selectedGearType.rawValue,
                        name: selectedAuxillaryPercussion.rawValue,
                        notes: backlineGearNotes.isReallyEmpty ? nil : backlineGearNotes
                    )
                }
            }

            let backlineItemDocumentId = try DatabaseService.shared.addBacklineItemToShow(
                backlineItem: backlineItem,
                drumKitBacklineItem: drumKitBacklineItem,
                show: show
            )
            viewState = .workCompleted
            return backlineItemDocumentId
        } catch {
            viewState = .error(message: error.localizedDescription)
            return ""
        }
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
