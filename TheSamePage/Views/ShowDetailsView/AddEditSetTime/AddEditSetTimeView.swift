//
//  AddEditSetTimeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/6/23.
//

import SwiftUI

struct AddEditSetTimeView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel: AddEditSetTimeViewModel

    init(show: Show, showParticipant: ShowParticipant) {
        _viewModel = StateObject(wrappedValue: AddEditSetTimeViewModel(show: show, showParticipant: showParticipant))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Set Time",
                        selection: $viewModel.bandSetTime,
                        displayedComponents: .hourAndMinute
                    )
                } footer: {
                    Text("Add the time that this band will be playing their set.")
                }

                Section {
                    AsyncButton {
                        await viewModel.addEditSetTime()
                    } label: {
                        Text("Save Set Time")
                    }
                    .disabled(viewModel.disableButtonsAndDismissal)
                }

                if viewModel.showParticipant.setTime != nil {
                    Section {
                        Button("Delete Set Time") {
                            viewModel.deleteSetTimeConfirmationAlertIsShowing.toggle()
                        }
                        .tint(.red)
                        .disabled(viewModel.disableButtonsAndDismissal)
                        .alert(
                            "Are You Sure?",
                            isPresented: $viewModel.deleteSetTimeConfirmationAlertIsShowing,
                            actions: {
                                Button("Cancel", role: .cancel) { }
                                Button("Yes", role: .destructive) {
                                    Task {
                                        await viewModel.deleteSetTime()
                                    }
                                }
                            },
                            message: { Text("This band will no longer have a set time for this show.") }
                        )
                    }
                }
            }
            .navigationTitle("Change Set Time")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(viewModel.disableButtonsAndDismissal)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .disabled(viewModel.disableButtonsAndDismissal)
                }
            }
            .onChange(of: viewModel.setTimeChangedSuccessfully) { setTimeChangedSuccessfully in
                if setTimeChangedSuccessfully {
                    dismiss()
                }
            }
            .errorAlert(isPresented: $viewModel.errorAlertIsShowing, message: viewModel.errorAlertText)
        }
    }
}

struct AddEditSetTimeView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditSetTimeView(show: Show.example, showParticipant: ShowParticipant.example)
    }
}
