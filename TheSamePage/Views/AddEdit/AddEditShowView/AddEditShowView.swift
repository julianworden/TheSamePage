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
    
    init(viewTitleText: String, showToEdit: Show?) {
        _viewModel = StateObject(wrappedValue: AddEditShowViewModel(viewTitleText: viewTitleText, showToEdit: showToEdit))
    }
    
    var body: some View {
        Form {
            if viewModel.showToEdit == nil {
                ImageSelectionButton(imagePickerIsShowing: $imagePickerIsShowing, selectedImage: $showImage)
            }
            
            Section {
                TextField("Name", text: $viewModel.showName)
                TextField("Venue", text: $viewModel.showVenue)
                TextField("Host Name (Company or Person)", text: $viewModel.showHostName)
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
                    Text("No show address selected")
                        .italic()
                }
                
                NavigationLink {
                    AddEditShowAddressView(viewModel: viewModel, showAddress: $showAddress)
                } label: {
                    Text("Select Address")
                }
                
                Toggle("Publicly display show address", isOn: $viewModel.addressIsPubliclyVisible)
            } header: {
                Text("Address")
            } footer: {
                Text(viewModel.publiclyVisibleAddressExplanation)
            }
            
            Section {
                TextField("Ticket Price", text: $viewModel.ticketPrice)
                    .keyboardType(.numberPad)
                Toggle("Are ticket sales required?", isOn: $viewModel.ticketSalesAreRequired)
                if viewModel.ticketSalesAreRequired {
                    TextField("How many must be sold?", text: $viewModel.minimumRequiredTicketsSold)
                        .keyboardType(.numberPad)
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
        .sheet(isPresented: $imagePickerIsShowing) {
            ImagePicker(image: $showImage, pickerIsShowing: $imagePickerIsShowing)
        }
    }
}

struct AddEditShowView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowView(viewTitleText: "Add Show", showToEdit: nil)
    }
}
