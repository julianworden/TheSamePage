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
        NavigationStack {
            ZStack {
                BackgroundColor()

                switch viewModel.viewState {
                case .dataLoading:
                    ProgressView()

                case .dataLoaded, .performingWork, .workCompleted, .error:
                    if viewModel.band.loggedInUserIsBandAdmin {
                        Form {
                            Section {
                                NavigationLink {
                                    AddEditBandView(bandToEdit: viewModel.band)
                                } label: {
                                    Text("Edit Band Info")
                                }
                                .disabled(viewModel.buttonsAreDisabled)

                                NavigationLink {
                                    ChooseNewBandAdminView(band: viewModel.band)
                                } label: {
                                    Text("Choose New Band Admin")
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
                                .disabled(viewModel.buttonsAreDisabled)
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
                        .navigationBarBackButtonHidden(viewModel.buttonsAreDisabled)
                    }

                default:
                    ErrorMessage(message: ErrorMessageConstants.invalidViewState)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                }
            }
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText
            )
            .task {
                await viewModel.getLatestBandData()
                if !viewModel.band.loggedInUserIsBandAdmin {
                    dismiss()
                }
            }
            .onChange(of: viewModel.bandDeleteWasSuccessful) { bandDeleteWasSuccessful in
                if bandDeleteWasSuccessful {
                    dismiss()
                }
            }
        }
    }
}

struct BandSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        BandSettingsView(band: Band.example)
    }
}
