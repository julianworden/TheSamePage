//
//  AddEditBandView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import SwiftUI

struct AddEditBandView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddEditBandViewModel
    
    @Binding var userIsOnboarding: Bool

    init(userIsOnboarding: Binding<Bool> = .constant(false), bandToEdit: Band? = nil, isPresentedModally: Bool = false) {
        _userIsOnboarding = Binding(projectedValue: userIsOnboarding)
        _viewModel = StateObject(
            wrappedValue: AddEditBandViewModel(
                bandToEdit: bandToEdit,
                userIsOnboarding: userIsOnboarding.wrappedValue,
                isPresentedModally: isPresentedModally
            )
        )
    }
    
    var body: some View {
        Form {
            Section("Info") {
                if viewModel.bandToEdit == nil {
                    ImageSelectionButton(
                        imagePickerIsShowing: $viewModel.imagePickerIsShowing,
                        selectedImage: $viewModel.selectedImage
                    )
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
                AsyncButton {
                    await viewModel.createUpdateBandButtonTapped()
                } label: {
                    Text(viewModel.bandToEdit == nil ? "Create Band" : "Update Band Info")
                }
                .disabled(viewModel.bandCreationButtonIsDisabled)
            }
        }
        .navigationTitle(viewModel.bandToEdit == nil ? "Create a Band" : "Update Band Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isPresentedModally {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.imagePickerIsShowing) {
            ImagePicker(image: $viewModel.selectedImage, pickerIsShowing: $viewModel.imagePickerIsShowing)
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
        .onChange(of: viewModel.userIsOnboarding) { userIsOnboarding in
            if !userIsOnboarding {
                self.userIsOnboarding = userIsOnboarding
            }
        }
        .onChange(of: viewModel.dismissView) { dismissView in
            if dismissView {
                dismiss()
            }
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
