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
        NavigationStack {
            ZStack {
                BackgroundColor()

                switch viewModel.viewState {
                case .dataLoading:
                    ProgressView()

                case .dataLoaded, .performingWork, .error:
                    if viewModel.show.loggedInUserIsShowHost {
                        Form {
                            Section {
                                NavigationLink {
                                    AddEditShowView(showToEdit: viewModel.show)
                                } label: {
                                    Text("Edit Show Info")
                                }
                                .disabled(viewModel.buttonsAreDisabled)

                                if !viewModel.show.alreadyHappened {
                                    NavigationLink {
                                        ChooseNewShowHostView(show: viewModel.show)
                                    } label: {
                                        Text("Choose New Show Host")
                                    }
                                    .disabled(viewModel.buttonsAreDisabled)
                                }
                            }

                            if !viewModel.show.alreadyHappened {
                                Section {
                                    Button(role: .destructive) {
                                        viewModel.cancelShowAlertIsShowing = true
                                    } label: {
                                        HStack(spacing: 5) {
                                            Text("Cancel Show")
                                            if viewModel.viewState == .performingWork {
                                                ProgressView()
                                            }
                                        }
                                    }
                                    .disabled(viewModel.buttonsAreDisabled)
                                    .alert(
                                        "Are You Sure?",
                                        isPresented: $viewModel.cancelShowAlertIsShowing,
                                        actions: {
                                            Button("Cancel", role: .cancel) { }
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
                            }
                        }
                        .navigationTitle("Show Settings")
                        .navigationBarTitleDisplayMode(.inline)
                    }

                case .workCompleted:
                    EmptyView()

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
                message: viewModel.errorAlertText,
                tryAgainAction: { await viewModel.cancelShow() }
            )
            .task {
                await viewModel.getLatestShowData()
                if !viewModel.show.loggedInUserIsShowHost {
                    dismiss()
                }
            }
            .onChange(of: viewModel.showDeleteWasSuccessful) { showDeleteWasSuccessful in
                if showDeleteWasSuccessful {
                    dismiss()
                }
            }
        }
    }
}

struct ShowSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowSettingsView(show: Show.example)
    }
}
