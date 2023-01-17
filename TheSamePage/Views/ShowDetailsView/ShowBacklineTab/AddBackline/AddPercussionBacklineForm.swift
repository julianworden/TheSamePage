//
//  AddPercussionBacklineForm.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import SwiftUI

struct AddPercussionBacklineForm: View {
    @ObservedObject var viewModel: AddBacklineViewModel
    
    var body: some View {
        Group {
            Picker("Select gear type", selection: $viewModel.selectedPercussionGearType) {
                ForEach(PercussionGearType.allCases) { percussionGearType in
                    Text(percussionGearType.rawValue)
                }
            }
            
            switch viewModel.selectedPercussionGearType {
            case .fullKit:
                Group {
                    Toggle("Kick", isOn: $viewModel.kickIncluded)
                    Toggle("Snare", isOn: $viewModel.snareIncluded)
                    Toggle("Toms", isOn: $viewModel.tomsIncluded)
                    
                    if viewModel.tomsIncluded {
                        Stepper(
                            "Number of toms: \(viewModel.numberOfTomsIncluded)",
                            onIncrement: { viewModel.incrementNumberOfTomsIncluded() },
                            onDecrement: { viewModel.decrementNumberOfTomsIncluded() }
                        )
                    }
                    
                    Toggle("Hi-Hat", isOn: $viewModel.hiHatIncluded)
                    
                    Toggle("Cymbals", isOn: $viewModel.cymbalsIncluded)
                    
                    if viewModel.cymbalsIncluded {
                        Stepper(
                            "Number of cymbals: \(viewModel.numberOfCymbalsIncluded)",
                            onIncrement: { viewModel.incrementNumberOfCymbalsIncluded() },
                            onDecrement: { viewModel.decrementNumberOfCymbalsIncluded() }
                        )
                        
                        Toggle("Cymbal Stands", isOn: $viewModel.cymbalStandsIncluded)
                        
                        if viewModel.cymbalStandsIncluded {
                            Stepper(
                                "Number of cymbal stands: \(viewModel.numberOfCymbalStandsIncluded)",
                                onIncrement: { viewModel.incrementNumberOfCymbalStandsIncluded() },
                                onDecrement: { viewModel.decrementNumberOfCymbalStandsIncluded() }
                            )
                        }
                    }
                }

            case .kitPiece:
                Picker("Select Kit Piece", selection: $viewModel.selectedDrumKitPiece) {
                    ForEach(DrumKitPiece.allCases) { drumKitPiece in
                        Text(drumKitPiece.rawValue)
                    }
                }
                
            case .auxillaryPercussion:
                Picker("Select Instrument", selection: $viewModel.selectedAuxillaryPercussion) {
                    ForEach(AuxillaryPercussion.allCases) { auxillaryPercussion in
                        Text(auxillaryPercussion.rawValue)
                    }
                }
            }
        }
    }
}

struct DrumBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        AddPercussionBacklineForm(viewModel: AddBacklineViewModel(show: Show.example))
    }
}
