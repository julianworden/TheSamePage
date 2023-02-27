
//  AddShowTimeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import SwiftUI

struct AddEditShowTimeView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: AddEditShowTimeViewModel

    init(show: Show, showTimeType: ShowTimeType) {
        _viewModel = StateObject(wrappedValue: AddEditShowTimeViewModel(show: show, showTimeType: showTimeType))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("\(viewModel.showTimeType.rawValue) Time", selection: $viewModel.showTime, displayedComponents: .hourAndMinute)
                }

                Section {
                    AsyncButton {
                        await viewModel.addShowTime()
                    } label: {
                        Text("Save Time")
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                }

                if viewModel.showTimeIsBeingEdited {
                    Section {
                        AsyncButton {
                            viewModel.deleteSetTimeConfirmationAlertIsShowing.toggle()
                        } label: {
                            Text("Delete Time")
                        }
                        .tint(.red)
                        .disabled(viewModel.buttonsAreDisabled)
                        .alert(
                            "Are You Sure?",
                            isPresented: $viewModel.deleteSetTimeConfirmationAlertIsShowing,
                            actions: {
                                Button("Cancel", role: .cancel) { }
                                Button("Yes", role: .destructive) {
                                    Task {
                                        await viewModel.deleteShowTime()
                                    }
                                }
                            },
                            message: { Text("This show will no longer have a \(viewModel.showTimeType.rawValue.lowercased()) time.") }
                        )
                    }
                }
            }
            .navigationTitle("Edit Show Time")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(viewModel.buttonsAreDisabled)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                }
            }
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText
            )
            .onChange(of: viewModel.asyncOperationCompleted) { showTimeSuccessfullyCreated in
                if showTimeSuccessfullyCreated {
                    dismiss()
                }
            }
        }
    }
}


struct AddShowTimeView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditShowTimeView(show: Show.example, showTimeType: .loadIn)
    }
}
