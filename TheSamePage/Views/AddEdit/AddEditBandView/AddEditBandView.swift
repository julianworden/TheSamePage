//
//  AddEditBandView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

// TODO: Ask user if they play in this band.

import SwiftUI

struct AddEditBandView: View {
    @StateObject var viewModel: AddEditBandViewModel
    
    @Binding var userIsOnboarding: Bool
    
    @State private var imagePickerIsShowing = false
    @State private var selectedImage: UIImage?
    @State private var bandCreationWasSuccessful = false
    @State private var bandCreationButtonIsDisabled = false
    
    init(userIsOnboarding: Binding<Bool>, band: Band?) {
        _userIsOnboarding = Binding(projectedValue: userIsOnboarding)
        _viewModel = StateObject(wrappedValue: AddEditBandViewModel(band: band))
    }
    
    var body: some View {
        Form {
            Section("Info") {
                ImageSelectionButton(imagePickerIsShowing: $imagePickerIsShowing, selectedImage: $selectedImage)
                TextField("Name", text: $viewModel.bandName)
                Picker("Genre", selection: $viewModel.bandGenre) {
                    ForEach(Genre.allCases) { genre in
                        Text(genre.rawValue)
                    }
                }
                Toggle("Do you play in this band?", isOn: $viewModel.userPlaysInBand)
                
                if viewModel.userPlaysInBand {
                    Picker("What's your role in this band?", selection: $viewModel.userRoleInBand) {
                        ForEach(Instrument.allCases) { instrument in
                            Text(instrument.rawValue)
                        }
                    }
                }
                // TODO: Only display this option when a band is being created, not edited
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
                Button("Create Band") {
                    Task {
                        do {
                            bandCreationButtonIsDisabled = true
                            try await viewModel.createBand(withImage: selectedImage)
                            bandCreationWasSuccessful = true
                            userIsOnboarding = false
                        } catch {
                            bandCreationButtonIsDisabled = false
                            print(error)
                        }
                    }
                }
                .disabled(bandCreationButtonIsDisabled)
            }
        }
        .navigationTitle("Create a band")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $imagePickerIsShowing) {
            ImagePicker(image: $selectedImage, pickerIsShowing: $imagePickerIsShowing)
        }
    }
}

struct AddEditBandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddEditBandView(userIsOnboarding: .constant(false), band: Band.example)
        }
    }
}
