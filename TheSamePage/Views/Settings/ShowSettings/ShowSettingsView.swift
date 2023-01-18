//
//  ShowSettingsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/14/22.
//

import SwiftUI

struct ShowSettingsView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel: ShowSettingsViewModel
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ShowSettingsViewModel(show: show))
    }
    
    var body: some View {
        Form {
            Button("Edit Show") {
                viewModel.addEditShowSheetIsShowing = true
            }
            
            Button("Cancel Show", role: .destructive) {
                viewModel.cancelShowAlertIsShowing = true
            }
            .alert(
                "Are you sure?",
                isPresented: $viewModel.cancelShowAlertIsShowing,
                actions: {
                    Button("No", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        Task {
                            await viewModel.cancelShow()
                        }
                    }
                },
                message: {
                    Text("Cancelling this show will permanently delete all of its data from The Same Page, including its chat.")
                }
            )
        }
        .navigationTitle("Show Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back", role: .cancel) {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $viewModel.addEditShowSheetIsShowing) {
            NavigationView {
                AddEditShowView(showToEdit: viewModel.show)
                    .navigationViewStyle(.stack)
            }
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            tryAgainAction: { await viewModel.cancelShow() }
        )
    }
}

struct ShowSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowSettingsView(show: Show.example)
    }
}
