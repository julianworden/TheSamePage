//
//  ChooseNewShowHostView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/31/23.
//

import SwiftUI

struct ChooseNewShowHostView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: ChooseNewShowHostViewModel

    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ChooseNewShowHostViewModel(show: show))
    }

    var body: some View {
        ZStack {
            BackgroundColor()

            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()

            case .dataNotFound:
                NoDataFoundMessage(message: "This show doesn't have any participants, so a new host can't be chosen.")

            case .dataLoaded, .workCompleted, .performingWork:
                List {
                    Section {
                        ForEach(viewModel.usersParticipatingInShow) { user in
                            Button(user.fullName) {
                                viewModel.selectNewShowHostConfirmationAlertIsShowing.toggle()
                            }
                            .disabled(viewModel.showHostIsBeingSet)
                            .alert(
                                "Are You Sure?",
                                isPresented: $viewModel.selectNewShowHostConfirmationAlertIsShowing,
                                actions: {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Yes", role: .destructive) {
                                        Task {
                                            await viewModel.setNewShowHost(user: user)
                                        }
                                    }
                                },
                                message: { Text("You will no longer be able make changes to this show if you are not the host. You also won't be able to access any of the show's private data, unless you are also in a band that's playing this show.") }
                            )
                        }
                    } footer: {
                        Text("If you'd like to choose a new show host that isn't already participating in this show, you'll need to invite them to join the show. If they accept, they can then be chosen as the new show host.")
                    }
                }

            case .error:
                EmptyView()

            default:
                ErrorMessage(message: ErrorMessageConstants.invalidViewState)
            }
        }
        .navigationTitle("Choose New Show Host")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.showHostIsBeingSet)
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
        .task {
            await viewModel.getUsersParticipatingInShow()
        }
        .onChange(of: viewModel.newHostSelectionWasSuccessful) { newHostSelectionWasSuccessful in
            if newHostSelectionWasSuccessful {
                dismiss()
            }
        }
    }
}

struct GiveUpShowHostRoleView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseNewShowHostView(show: Show.example)
    }
}
