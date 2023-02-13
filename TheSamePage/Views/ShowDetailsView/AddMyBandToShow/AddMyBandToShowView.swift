//
//  AddMyBandToShowView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/19/23.
//

import SwiftUI

struct AddMyBandToShowView: View {
    @StateObject private var viewModel: AddMyBandToShowViewModel

    @Environment(\.dismiss) var dismiss

    init(show: Show) {
        _viewModel = StateObject(wrappedValue: AddMyBandToShowViewModel(show: show))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.viewState {
                case .dataLoading:
                    ProgressView()

                case .dataLoaded, .workCompleted, .performingWork:
                    Form {
                        Section {
                            Picker("Choose a Band", selection: $viewModel.selectedBand) {
                                ForEach(viewModel.userBands) { band in
                                    Text(band.name).tag(band as Band?)
                                }
                            }
                            .id(viewModel.selectedBand)
                        }

                        Section {
                            AsyncButton {
                                await viewModel.addBandToShow()
                            } label: {
                                Text("Add Band to Show")
                            }
                            .disabled(viewModel.buttonsAreDisabled)
                            .alert(
                                "Error",
                                isPresented: $viewModel.invalidRequestAlertIsShowing,
                                actions: {
                                    Button("OK") { }
                                },
                                message: {
                                    Text(viewModel.invalidRequestAlertText)
                                }
                            )

                        }
                    }

                case .dataNotFound:
                    NoDataFoundMessage(message: "You are not the admin of any bands, you can only add bands of which you are the admin.")

                case .error:
                    EmptyView()

                default:
                    ErrorMessage(message: ErrorMessageConstants.invalidViewState)
                }
            }
            .navigationTitle("Add Band to Show")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(viewModel.buttonsAreDisabled)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                }
            }
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText,
                tryAgainAction: { await viewModel.getLoggedInUserBands() }
            )
            .task {
                await viewModel.getLoggedInUserBands()
            }
            .onChange(of: viewModel.bandAddedSuccessfully) { bandAddedSuccessfully in
                if bandAddedSuccessfully {
                    dismiss()
                }
            }
        }
    }
}

struct AddMyBandToShowView_Previews: PreviewProvider {
    static var previews: some View {
        AddMyBandToShowView(show: Show.example)
    }
}
