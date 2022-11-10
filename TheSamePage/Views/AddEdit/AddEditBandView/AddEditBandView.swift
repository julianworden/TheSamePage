//
//  AddEditBandView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

// TODO: Ask user if they play in this band.

import SwiftUI

struct AddEditBandView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddEditBandViewModel
    
    @Binding var userIsOnboarding: Bool
    
    @State private var imagePickerIsShowing = false
    @State private var selectedImage: UIImage?
    @State private var bandCreationButtonIsDisabled = false
    
    init(userIsOnboarding: Binding<Bool> = .constant(false), bandToEdit: Band? = nil) {
        _userIsOnboarding = Binding(projectedValue: userIsOnboarding)
        _viewModel = StateObject(wrappedValue: AddEditBandViewModel(bandToEdit: bandToEdit))
    }
    
    var body: some View {
        Form {
            Section("Info") {
                if viewModel.bandToEdit == nil {
                    ImageSelectionButton(imagePickerIsShowing: $imagePickerIsShowing, selectedImage: $selectedImage)
                }
                
                TextField("Name", text: $viewModel.bandName)
                Picker("Genre", selection: $viewModel.bandGenre) {
                    ForEach(Genre.allCases) { genre in
                        Text(genre.rawValue)
                    }
                }
                
                if viewModel.bandToEdit == nil {
                    Toggle("Do you play in this band?", isOn: $viewModel.userPlaysInBand)
                    
                    if viewModel.userPlaysInBand {
                        Picker("What's your role in this band?", selection: $viewModel.userRoleInBand) {
                            ForEach(Instrument.allCases) { instrument in
                                Text(instrument.rawValue)
                            }
                        }
                    }
                }
            }
            
            Section("Bio") {
                TextEditor(text: $viewModel.bandBio)
            }
            
            Section("Location") {
                TextField("City", text: $viewModel.bandCity)
                Picker("State", selection: $viewModel.bandState) {
                    ForEach(BandState.allCases) { state in
                        Text(state.rawValue)
                    }
                }
            }
            
            Section {
                Button {
                    Task {
                        do {
                            bandCreationButtonIsDisabled = true
                            if viewModel.bandToEdit == nil {
                                try await viewModel.createBand(withImage: selectedImage)
                            } else {
                                await viewModel.updateBand()
                            }
                            
                            if userIsOnboarding {
                                userIsOnboarding = false
                            } else {
                                dismiss()
                            }
                        } catch {
                            bandCreationButtonIsDisabled = false
                            print(error)
                        }
                    }
                } label: {
                    AsyncButtonLabel(buttonIsDisabled: $bandCreationButtonIsDisabled, title: viewModel.bandToEdit == nil ? "Create Band" : "Update Band Info")
                }
                .disabled(bandCreationButtonIsDisabled)
            }
        }
        .navigationTitle(viewModel.bandToEdit == nil ? "Create a Band" : "Update Band Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.bandToEdit != nil {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $imagePickerIsShowing) {
            ImagePicker(image: $selectedImage, pickerIsShowing: $imagePickerIsShowing)
        }
    }
}

struct AddEditBandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddEditBandView(userIsOnboarding: .constant(false), bandToEdit: Band.example)
        }
    }
}
