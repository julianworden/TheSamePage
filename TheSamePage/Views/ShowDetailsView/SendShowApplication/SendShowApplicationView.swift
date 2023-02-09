//
//  SendShowApplicationView.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/8/23.
//

import SwiftUI

struct SendShowApplicationView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: SendShowApplicationViewModel

    init(show: Show) {
        _viewModel = StateObject(wrappedValue: SendShowApplicationViewModel(show: show))
    }

    var body: some View {
        NavigationStack {
            Form {
                if !viewModel.adminBands.isEmpty {
                    Section {
                        Picker("Which band wants to play this show?", selection: $viewModel.selectedBand) {
                            ForEach(viewModel.adminBands) { band in
                                Text(band.name).tag(band as Band?)
                            }
                        }
                        .id(viewModel.selectedBand)
                    }

                    Section {
                        AsyncButton {
                            await viewModel.sendShowApplication()
                        } label: {
                            Text("Submit Show Application")
                        }
                        .disabled(viewModel.buttonsAreDisabled)
                    }
                } else if viewModel.adminBands.isEmpty {
                    NoDataFoundMessage(message: ErrorMessageConstants.userIsNotAdminOfAnyBands)
                }
            }
            .navigationTitle("Send Show Application")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(viewModel.buttonsAreDisabled)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText
            )
            .task {
                await viewModel.getLoggedInUserAdminBands()
            }
            .onChange(of: viewModel.asyncOperationCompletedSuccessfully) { asyncOperationCompletedSuccessfully in
                if asyncOperationCompletedSuccessfully {
                    dismiss()
                }
            }
        }
    }
}

struct SendShowApplicationView_Previews: PreviewProvider {
    static var previews: some View {
        SendShowApplicationView(show: Show.example)
    }
}
