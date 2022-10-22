//
//  AddBacklineView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import SwiftUI

struct AddBacklineView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddBacklineViewModel
    
    @State private var addGearButtonIsDisabled = false
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: AddBacklineViewModel(show: show))
    }
    
    var body: some View {
        // TODO: Won't compile if switch is used inside list. Use separate lists for each instrument type instead.
        Form {
            Section("What would you like to backline?") {
                Picker("Gear type", selection: $viewModel.selectedGearType) {
                    ForEach(BacklineItemType.allCases) { gearType in
                        Text(gearType.rawValue)
                    }
                }
                
                switch viewModel.selectedGearType {
                case .percussion:
                    AddPercussionBacklineForm(viewModel: viewModel)
                case .bassGuitar:
                    Picker("Select Bass Gear", selection: $viewModel.selectedGuitarGear) {
                        ForEach(GuitarGear.allCases) { guitarGear in
                            Text(guitarGear.rawValue)
                        }
                    }
                case .electricGuitar:
                    Picker("Select Guitar Gear", selection: $viewModel.selectedGuitarGear) {
                        ForEach(GuitarGear.allCases) { guitarGear in
                            Text(guitarGear.rawValue)
                        }
                    }
                }
            }
            
            Section {
                TextEditor(text: $viewModel.backlineGearNotes)
            } header: {
                Text("Notes (Gear make, model, etc.)")
            }

            Section {
                Button {
                    do {
                        addGearButtonIsDisabled = true
                        try viewModel.addBacklineItemToShow()
                        dismiss()
                    } catch {
                        addGearButtonIsDisabled = false
                        print(error)
                    }
                } label: {
                    AsyncButtonLabel(buttonIsDisabled: $addGearButtonIsDisabled, title: "Add Gear to Backline")
                }
                .disabled(addGearButtonIsDisabled)
            } footer: {
                Text("Do not backline someone else's gear on their behalf without their permission!")
            }
        }
        .navigationTitle("Add Backline Gear")
        .navigationBarTitleDisplayMode(.inline)
    }
}
    
    struct AddBacklineView_Previews: PreviewProvider {
        static var previews: some View {
            AddBacklineView(show: Show.example)
        }
    }
