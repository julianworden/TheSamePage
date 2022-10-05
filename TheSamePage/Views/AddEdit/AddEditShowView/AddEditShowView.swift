//
//  AddEditShowView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import SwiftUI

struct AddEditShowView: View {
    
    @StateObject var viewModel: AddEditShowViewModel
    
    @Binding var addEditShowViewIsShowing: Bool
    
    @State private var imagePickerIsShowing = false
    
    init(viewTitleText: String, addEditShowViewIsShowing: Binding<Bool>, showToEdit: Show?) {
        _viewModel = StateObject(wrappedValue: AddEditShowViewModel(viewTitleText: viewTitleText, showToEdit: showToEdit))
        _addEditShowViewIsShowing = Binding(projectedValue: addEditShowViewIsShowing)
    }
    
    var body: some View {
        NavigationView {
            Form {
                ImageSelectionButton(imagePickerIsShowing: $imagePickerIsShowing, selectedImage: $viewModel.showImage)
                
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
                
                // TODO: Add this to a new view that's shown when editing a show
//                Section {
//                    DatePicker("Load In", selection: $viewModel.showLoadInTime, in: viewModel.showDate..., displayedComponents: .hourAndMinute)
//                    DatePicker("Doors", selection: $viewModel.showDoorsTime, in: viewModel.showLoadInTime..., displayedComponents: .hourAndMinute)
//                    DatePicker("First Set", selection: $viewModel.showFirstSetTime, in: viewModel.showDoorsTime..., displayedComponents: .hourAndMinute)
//                    DatePicker("End", selection: $viewModel.showEndTime, in: viewModel.showFirstSetTime..., displayedComponents: .hourAndMinute)
//                }
                
                Section {
                    Toggle("21+", isOn: $viewModel.showIs21Plus)
                    Toggle("Food", isOn: $viewModel.showHasFood)
                    Toggle("Bar", isOn: $viewModel.showHasBar)
                }
                
                Section {
                    Button("Create Show") {
                        Task {
                            do {
                                try await viewModel.createShow()
                                addEditShowViewIsShowing = false
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.viewTitleText)
            .sheet(isPresented: $imagePickerIsShowing) {
                ImagePicker(image: $viewModel.showImage, pickerIsShowing: $imagePickerIsShowing)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        addEditShowViewIsShowing = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .animation(.easeInOut, value: viewModel.showDateIsKnown)
        }
    }
}

struct AddEditShowView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowView(viewTitleText: "Add Show", addEditShowViewIsShowing: .constant(true), showToEdit: nil)
    }
}
