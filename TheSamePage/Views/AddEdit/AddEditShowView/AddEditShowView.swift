//
//  AddEditShowView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import SwiftUI

struct AddEditShowView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddEditShowViewModel
    
    init(showToEdit: Show?, isPresentedModally: Bool = false) {
        _viewModel = StateObject(wrappedValue: AddEditShowViewModel(showToEdit: showToEdit, isPresentedModally: isPresentedModally))
    }
    
    var body: some View {
        Form {
            if viewModel.showToEdit == nil {
                ImageSelectionButton(
                    imagePickerIsShowing: $viewModel.imagePickerIsShowing,
                    selectedImage: $viewModel.showImage
                )
            }
            
            Section {
                TextField("Name (required)", text: $viewModel.showName)
                TextField("Venue (required)", text: $viewModel.showVenue)
                TextField("Host Name (required)", text: $viewModel.showHostName)
                Picker("Genre", selection: $viewModel.showGenre) {
                    ForEach(Genre.allCases) { genre in
                        Text(genre.rawValue)
                    }
                }
                DatePicker("Date", selection: $viewModel.showDate, in: Date.now..., displayedComponents: .date)
            }
            
            Section {
                TextField("Description", text: $viewModel.showDescription, axis: .vertical)
            }
            
            Section {
                Stepper {
                    Text("Max Number of Bands: \(viewModel.showMaxNumberOfBands)")
                } onIncrement: {
                    viewModel.incrementMaxNumberOfBands()
                } onDecrement: {
                    viewModel.decrementMaxNumberOfBands()
                }
            }
            
            Section {
                if let showAddress = viewModel.showAddress {
                    Text(showAddress)
                } else {
                    Text("No address selected")
                        .italic()
                }
                
                NavigationLink {
                    AddEditShowAddressView(showToEdit: viewModel.showToEdit)
                } label: {
                    Text("Select Address (required)")
                }
                
                Toggle("Publicly display show address", isOn: $viewModel.addressIsPrivate)
            } header: {
                Text("Address")
            } footer: {
                Text(viewModel.publiclyVisibleAddressExplanation)
            }
            
            Section {
                Toggle("Admission is free", isOn: $viewModel.showIsFree)
                
                if !viewModel.showIsFree {
                    TextField("Ticket Price (required)", text: $viewModel.ticketPrice)
                        .keyboardType(.numberPad)
                    Toggle("Show Has Ticket Quota", isOn: $viewModel.ticketSalesAreRequired)
                    
                    if viewModel.ticketSalesAreRequired {
                        TextField("How many tickets must be sold? (required)", text: $viewModel.minimumRequiredTicketsSold)
                            .keyboardType(.numberPad)
                    }
                }
            } footer: {
                if !viewModel.ticketSalesAreRequired {
                    Text("In some cases, bands may be required to sell a certain amount of tickets prior to the day of the show. Enable this option if that is the case for this show.")
                }
            }
            
            Section {
                Toggle("21+", isOn: $viewModel.showIs21Plus)
                Toggle("Food", isOn: $viewModel.showHasFood)
                Toggle("Bar", isOn: $viewModel.showHasBar)
            }
            
            Section {
                AsyncButton {
                    _ = await viewModel.updateCreateShowButtonTapped(withImage: viewModel.showImage)
                } label: {
                    Text("\(viewModel.showToEdit != nil ? "Update Show Info" : "Create Show")")
                }
                .disabled(viewModel.buttonsAreDisabled)
            }
        }
        .navigationTitle(viewModel.showToEdit == nil ? "Create Show" : "Update Show ifno")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isPresentedModally {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                }
            }
        }
        .sheet(isPresented: $viewModel.imagePickerIsShowing) {
            ImagePicker(image: $viewModel.showImage, pickerIsShowing: $viewModel.imagePickerIsShowing)
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
        .onAppear {
            viewModel.addShowAddressObserver()
        }
        .onChange(of: viewModel.showCreatedSuccessfully) { _ in
            dismiss()
        }
    }
}

struct AddEditShowView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowView(showToEdit: nil)
    }
}
