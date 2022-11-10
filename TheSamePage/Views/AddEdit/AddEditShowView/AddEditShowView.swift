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
    
    @State var showImage: UIImage?
    @State private var showAddress: String?
    
    @State private var imagePickerIsShowing = false
    @State private var bandSearchSheetIsShowing = false
    @State private var createShowButtonIsDisabled = false
    @State private var missingFieldsAlertIsShowing = false
    
    init(viewTitleText: String, showToEdit: Show?) {
        _viewModel = StateObject(wrappedValue: AddEditShowViewModel(viewTitleText: viewTitleText, showToEdit: showToEdit))
    }
    
    var body: some View {
        Form {
            if viewModel.showToEdit == nil {
                ImageSelectionButton(imagePickerIsShowing: $imagePickerIsShowing, selectedImage: $showImage)
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
                DatePicker("Date", selection: $viewModel.showDate, in: viewModel.showDate..., displayedComponents: .date)
            }
            
            Section("Description") {
                TextEditor(text: $viewModel.showDescription)
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
                    AddEditShowAddressView(viewModel: viewModel, showAddress: $showAddress)
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
                Toggle("Show is free", isOn: $viewModel.showIsFree)
                
                if !viewModel.showIsFree {
                    TextField("Ticket Price (required)", text: $viewModel.ticketPrice)
                        .keyboardType(.numberPad)
                    Toggle("Are ticket sales required?", isOn: $viewModel.ticketSalesAreRequired)
                    
                    if viewModel.ticketSalesAreRequired {
                        TextField("How many must be sold? (required)", text: $viewModel.minimumRequiredTicketsSold)
                            .keyboardType(.numberPad)
                    } 
                }
            }
            
            Section {
                Toggle("21+", isOn: $viewModel.showIs21Plus)
                Toggle("Food", isOn: $viewModel.showHasFood)
                Toggle("Bar", isOn: $viewModel.showHasBar)
            }
            
            Section {
                Button {
                    Task {
                        do {
                            createShowButtonIsDisabled = true
                            if viewModel.showToEdit == nil {
                                try await viewModel.createShow(withImage: showImage)
                            } else {
                                try await viewModel.updateShow()
                            }
                            dismiss()
                        } catch AddEditShowViewModelError.incompleteForm {
                            missingFieldsAlertIsShowing = true
                            createShowButtonIsDisabled = false
                        } catch {
                            createShowButtonIsDisabled = false
                            print(error)
                        }
                    }
                } label: {
                    AsyncButtonLabel(buttonIsDisabled: $createShowButtonIsDisabled, title: "\(viewModel.showToEdit != nil ? "Update Show" : "Create Show")")
                }
                .disabled(createShowButtonIsDisabled)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.viewTitleText)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.showToEdit != nil {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $imagePickerIsShowing) {
            ImagePicker(image: $showImage, pickerIsShowing: $imagePickerIsShowing)
        }
        .alert(
            "Error",
            isPresented: $missingFieldsAlertIsShowing,
            actions: {
                Button("OK") { }
            }, message: {
                Text("Please ensure that all required fields are filled.")
            }
        )
    }
}

struct AddEditShowView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowView(viewTitleText: "Add Show", showToEdit: nil)
    }
}
