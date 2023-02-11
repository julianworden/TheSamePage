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

                case .dataLoaded:
                    if viewModel.show.loggedInUserIsShowHost {
                        Form {
                            Section {
                                NavigationLink {
                                    AddEditShowView(showToEdit: viewModel.show)
                                } label: {
                                    Text("Edit Show Info")
                                }

                                if !viewModel.show.alreadyHappened {
                                    NavigationLink {
                                        ChooseNewShowHostView(show: viewModel.show)
                                    } label: {
                                        Text("Choose New Show Host")
                                    }
                                }
                            }

                            if !viewModel.show.alreadyHappened {
                                Section {
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
                            }
                        }
                        .navigationTitle("Show Settings")
                        .navigationBarTitleDisplayMode(.inline)
                    }

                case .error:
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
        }
    }
}

struct ShowSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ShowSettingsView(show: Show.example)
    }
}
