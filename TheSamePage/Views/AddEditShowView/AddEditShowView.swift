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
    
    @State private var showImage: Image?
    
    init(viewTitleText: String, addEditShowViewIsShowing: Binding<Bool>, show: Show? = nil) {
        _viewModel = StateObject(wrappedValue: AddEditShowViewModel(viewTitleText: viewTitleText))
        _addEditShowViewIsShowing = Binding(projectedValue: addEditShowViewIsShowing)
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let showImage {
                    showImage
                } else {
                    Button {
                        // TODO: Show options for PHPhotoPicker
                    } label: {
                        NoImageView()
                    }
                }
                
                Section {
                    TextField("Name", text: $viewModel.showName)
                    TextEditor(text: $viewModel.showDescription)
                    TextField("Venue", text: $viewModel.showVenue)
                    DatePicker("Date", selection: $viewModel.showDate, in: viewModel.showDate..., displayedComponents: .date)
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
                    DatePicker("Load In", selection: $viewModel.showLoadInTime, in: viewModel.showDate..., displayedComponents: .hourAndMinute)
                    DatePicker("Doors", selection: $viewModel.showDoorsTime, in: viewModel.showLoadInTime..., displayedComponents: .hourAndMinute)
                    DatePicker("First Set", selection: $viewModel.showFirstSetTime, in: viewModel.showDoorsTime..., displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $viewModel.showEndTime, in: viewModel.showFirstSetTime..., displayedComponents: .hourAndMinute)
                }
                
                Section {
                    Toggle("21+", isOn: $viewModel.showIs21Plus)
                    Toggle("Food", isOn: $viewModel.showHasFood)
                    Toggle("Bar", isOn: $viewModel.showHasBar)
                }
                
                Section {
                    Button("Create Show") {
                        do {
                            try viewModel.createShow()
                            addEditShowViewIsShowing = false
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.viewTitleText)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        addEditShowViewIsShowing = false
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct AddEditShowView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowView(viewTitleText: "Add Show", addEditShowViewIsShowing: .constant(true))
    }
}