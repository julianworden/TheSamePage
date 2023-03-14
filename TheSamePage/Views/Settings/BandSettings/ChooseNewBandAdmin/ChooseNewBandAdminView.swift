//
//  ChooseNewBandAdminView.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/1/23.
//

import SwiftUI

struct ChooseNewBandAdminView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: ChooseNewBandAdminViewModel

    init(band: Band) {
        _viewModel = StateObject(wrappedValue: ChooseNewBandAdminViewModel(band: band))
    }

    var body: some View {
        ZStack {
            BackgroundColor()

            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()

            case .dataNotFound:
                NoDataFoundMessage(message: "This band doesn't have any members that can become the new band admin.")

            case .dataLoaded, .workCompleted, .performingWork, .error:
                List {
                    Section {
                        ForEach(viewModel.usersPlayingInBand) { user in
                            Button(user.fullName) {
                                viewModel.selectNewBandAdminConfirmationAlertIsShowing.toggle()
                            }
                            .disabled(viewModel.bandAdminIsBeingSet)
                            .alert(
                                "Are You Sure?",
                                isPresented: $viewModel.selectNewBandAdminConfirmationAlertIsShowing,
                                actions: {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Yes", role: .destructive) {
                                        Task {
                                            await viewModel.setNewBandAdmin(user: user)
                                        }
                                    }
                                },
                                message: { Text("You will no longer be able make changes to this band's info if you are not the admin. You also won't be able to access any of the band's private data, unless you are also a member of this band.") }
                            )
                        }
                    } footer: {
                        Text("If you'd like to choose a new band admin that isn't already a member of this band, you'll need to invite them to join the band. If they accept, they can then be chosen as the new band admin.")
                    }
                }

            default:
                ErrorMessage(message: ErrorMessageConstants.invalidViewState)
            }
        }
        .navigationTitle("Choose New Band Admin")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.bandAdminIsBeingSet)
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
        .task {
            await viewModel.getUsersPlayingInBand()
        }
        .onChange(of: viewModel.newAdminSelectionWasSuccessful) { newAdminSelectionWasSuccessful in
            if newAdminSelectionWasSuccessful {
                dismiss()
            }
        }
    }
}

struct ChooseNewBandAdminView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseNewBandAdminView(band: Band.example)
    }
}
