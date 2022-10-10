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
    
    @State private var imagePickerIsShowing = false
    @State private var bandSearchSheetIsShowing = false
    @State private var createShowButtonIsDisabled = false
    
    init(viewTitleText: String, showToEdit: Show?) {
        _viewModel = StateObject(wrappedValue: AddEditShowViewModel(viewTitleText: viewTitleText, showToEdit: showToEdit))
    }
    
    var body: some View {
        Form {
            ImageSelectionButton(imagePickerIsShowing: $imagePickerIsShowing, selectedImage: $showImage)
            
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
                    Text("Max number of bands: \(viewModel.showMaxNumberOfBands)")
                } onIncrement: {
                    viewModel.incrementMaxNumberOfBands()
                } onDecrement: {
                    viewModel.decrementMaxNumberOfBands()
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
                            try await viewModel.createShow(withImage: showImage)
                            dismiss()
                        } catch {
                            createShowButtonIsDisabled = false
                            print(error)
                        }
                    }
                } label: {
                    AsyncButtonLabel(buttonIsDisabled: $createShowButtonIsDisabled, title: "Create Show")
                }
                .disabled(createShowButtonIsDisabled)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.viewTitleText)
        .sheet(isPresented: $imagePickerIsShowing) {
            ImagePicker(image: $showImage, pickerIsShowing: $imagePickerIsShowing)
        }
        .animation(.easeInOut, value: viewModel.showDateIsKnown)
    }
}

struct AddEditShowView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowView(viewTitleText: "Add Show", showToEdit: nil)
    }
}
