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

    init(show: Show) {
        _viewModel = StateObject(wrappedValue: AddBacklineViewModel(show: show))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("What kind of gear would you like to backline?") {
                    Picker("Gear type", selection: $viewModel.selectedGearType) {
                        ForEach(BacklineItemType.allCases) { gearType in
                            Text(gearType.rawValue)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: UiConstants.backlineWheelPickerHeight)

                    switch viewModel.selectedGearType {
                    case .percussion:
                        AddPercussionBacklineForm(viewModel: viewModel)

                    case .bassGuitar:
                        Picker("Select Bass Gear", selection: $viewModel.selectedBassGuitarGear) {
                            ForEach(BassGuitarGear.allCases) { bassGuitarGear in
                                Text(bassGuitarGear.rawValue)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: UiConstants.backlineWheelPickerHeight)

                    case .electricGuitar:
                        Picker("Select Electric Guitar Gear", selection: $viewModel.selectedElectricGuitarGear) {
                            ForEach(ElectricGuitarGear.allCases) { electricGuitarGear in
                                Text(electricGuitarGear.rawValue)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: UiConstants.backlineWheelPickerHeight)

                    case .acousticGuitar:
                        Picker("Select Acoustic Guitar Gear", selection: $viewModel.selectedAcousticGuitarGear) {
                            ForEach(AcousticGuitarGear.allCases) { acousticGuitarGear in
                                Text(acousticGuitarGear.rawValue)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: UiConstants.backlineWheelPickerHeight)

                    case .keys:
                        Picker("Select Keys Gear", selection: $viewModel.selectedKeysGear) {
                            ForEach(KeysGearType.allCases) { keysGear in
                                Text(keysGear.rawValue)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: UiConstants.backlineWheelPickerHeight)

                    case .stageGear:
                        Picker("Select Stage Gear", selection: $viewModel.selectedStageGear) {
                            ForEach(StageGearType.allCases) { stageGear in
                                Text(stageGear.rawValue)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: UiConstants.backlineWheelPickerHeight)

                        if viewModel.selectedStageGear == .diBox || viewModel.selectedStageGear == .stageBox {
                            Stepper(
                                "\(viewModel.stageGearStepperText): \(viewModel.backlineItemCount)",
                                onIncrement: { viewModel.incrementBacklineItemCount() },
                                onDecrement: { viewModel.decrementBacklineItemCount() }
                            )
                        }
                    }
                }

                Section {
                    TextField("Notes (Make, Model, etc.)", text: $viewModel.backlineGearNotes, axis: .vertical)
                }

                Section {
                    AsyncButton {
                        await viewModel.addBacklineItemToShow()
                    } label: {
                        Text("Add Gear to Backline")
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                } footer: {
                    Text("Do not backline someone else's gear on their behalf without their permission!")
                }
            }
            .navigationTitle("Add Backline Gear")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(viewModel.buttonsAreDisabled)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                }
            }
            .onChange(of: viewModel.gearAddedSuccessfully) { gearAddedSuccessfully in
                if gearAddedSuccessfully {
                    dismiss()
                }
            }
        }
    }
}
    
    struct AddBacklineView_Previews: PreviewProvider {
        static var previews: some View {
            AddBacklineView(show: Show.example)
        }
    }
