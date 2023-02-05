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
    @Published var numberOfTomsIncluded = 0
    @Published var hiHatIncluded = false
    @Published var cymbalsIncluded = false
    @Published var numberOfCymbalsIncluded = 0
    @Published var cymbalStandsIncluded = false
    @Published var numberOfCymbalStandsIncluded = 0
    
    @Published var addGearButtonIsDisabled = false
    @Published var gearAddedSuccessfully = false

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    let show: Show

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                addGearButtonIsDisabled = true
            case .workCompleted:
                gearAddedSuccessfully = true
                addGearButtonIsDisabled = false
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                addGearButtonIsDisabled = false
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }

    init(show: Show) {
        self.show = show
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
                    drumKitBacklineItem = DrumKitBacklineItem(
                        backlinerUid: loggedInUser.id,
                        backlinerFullName: loggedInUser.fullName,
                        type: selectedGearType.rawValue,
                        name: selectedPercussionGearType.rawValue,
                        notes: backlineGearNotes.isReallyEmpty ? nil : backlineGearNotes,
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
