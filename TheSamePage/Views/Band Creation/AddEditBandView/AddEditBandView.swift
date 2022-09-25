//
//  AddEditBandView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

// TODO: Ask user if they play in this band.

import SwiftUI

struct AddEditBandView: View {
    @EnvironmentObject var userController: UserController
    
    @StateObject var viewModel = AddEditBandViewModel()
    
    @Binding var userIsOnboarding: Bool
    
    @State private var imagePickerIsShowing = false
    @State private var selectedImage: UIImage?
    @State private var bandCreationWasSuccessful = false
    @State private var bandCreationButtonIsDisabled = false
    
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
                Button {
                    Task {
                        do {
                            bandCreationButtonIsDisabled = true
                            userController.createdBand = try await viewModel.createBand(withImage: selectedImage)
                            bandCreationWasSuccessful = true
                        } catch {
                            bandCreationButtonIsDisabled = false
                            print(error)
                        }
                    }
                } label: {
                    NavigationLink(destination: InviteMembersView(userIsOnboarding: $userIsOnboarding), isActive: $bandCreationWasSuccessful) {
                        Text("Create Band")
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
            AddEditBandView(userIsOnboarding: .constant(false))
        }
    }
}
