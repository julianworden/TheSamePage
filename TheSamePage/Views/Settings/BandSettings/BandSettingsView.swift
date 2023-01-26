//
//  BandSettingsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/13/22.
//

import SwiftUI

struct BandSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: BandSettingsViewModel
    
    @State private var editBandSheetIsShowing = false
    @State private var leaveBandAlertIsShowing = false
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: BandSettingsViewModel(band: band))
    }
    
    var body: some View {
        let band = viewModel.band
        
        Form {
            Section {
                NavigationLink {
                    AddEditBandView(bandToEdit: band)
                } label: {
                    Text("Edit Band Info")
                }
                .disabled(viewModel.viewState == .performingWork)
                
                if band.loggedInUserIsBandAdmin {
                    // TODO: Add logic to make someone else band admin
                }
            }

            Section {
                Button(role: .destructive) {
                    viewModel.deleteBandConfirmationAlertIsShowing.toggle()
                } label: {
                    HStack(spacing: 5) {
                        Text("Delete Band")
                        if viewModel.viewState == .performingWork {
                            ProgressView()
                        }
                    }
                }
                .disabled(viewModel.viewState == .performingWork)
                .alert(
                    "Are You Sure?",
                    isPresented: $viewModel.deleteBandConfirmationAlertIsShowing,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                        Button("Yes", role: .destructive) {
                            Task {
                                await viewModel.deleteBand()
                            }
                        }
                    },
                    message: { Text("This band and all of its info will be permanently deleted. This cannot be undone.") }
                )
            }
        }
        .navigationTitle("Band Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.viewState == .performingWork)
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
        .onChange(of: viewModel.bandDeleteWasSuccessful) { bandDeleteWasSuccessful in
            if bandDeleteWasSuccessful {
                dismiss()
            }
        }
    }
}

struct BandSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BandSettingsView(band: Band.example)
    }
}
