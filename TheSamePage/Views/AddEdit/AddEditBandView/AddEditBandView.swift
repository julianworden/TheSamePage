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

    init(bandToEdit: Band? = nil, isPresentedModally: Bool = false) {
        _viewModel = StateObject(
            wrappedValue: AddEditBandViewModel(
                bandToEdit: bandToEdit,
                isPresentedModally: isPresentedModally
            )
        )
    }
    
    var body: some View {
        NavigationStack {
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

                Section {
                    TextField("Bio", text: $viewModel.bandBio, axis: .vertical)
                }

                Section("Location") {
                    TextField("City", text: $viewModel.bandCity)
                    Picker("State", selection: $viewModel.bandState) {
                        ForEach(UsState.allCases, id: \.self) { state in
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
                    .disabled(viewModel.buttonsAreDisabled)
                }
            }
            .navigationTitle(viewModel.bandToEdit == nil ? "Create a Band" : "Update Band Info")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(viewModel.buttonsAreDisabled)
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
                ImagePicker(image: $viewModel.selectedImage, pickerIsShowing: $viewModel.imagePickerIsShowing)
            }
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText
            )
            .onChange(of: viewModel.dismissView) { dismissView in
                if dismissView {
                    dismiss()
                }
            }
        }
    }
}

struct AddEditBandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddEditBandView(bandToEdit: Band.example)
        }
    }
}
