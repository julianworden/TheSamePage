//
//  SendShowInviteView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import SwiftUI

struct SendShowInviteView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: SendShowInviteViewModel

    init(band: Band) {
        _viewModel = StateObject(wrappedValue: SendShowInviteViewModel(band: band))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()

                switch viewModel.viewState {
                case .dataLoading:
                    ProgressView()

                case .dataLoaded, .performingWork, .workCompleted:
                    Form {
                        Picker("Which show would you like to invite \(viewModel.band.name) to?", selection: $viewModel.selectedShow) {
                            ForEach(viewModel.userShows) { show in
                                Text(show.name).tag(show as Show?)
                            }
                        }

                        AsyncButton {
                            await viewModel.sendShowInvite()
                        } label: {
                            Text("Send Invite")
                        }
                        .disabled(viewModel.buttonsAreDisabled)
                    }
                    .scrollDismissesKeyboard(.interactively)

                case .dataNotFound:
                    Text("No hosted shows found, you are not hosting any shows. You can create a show in the My Shows tab.")
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                default:
                    ErrorMessage(message: ErrorMessageConstants.invalidViewState)
                }
            }
            .navigationTitle("Send Show Invite")
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
            .alert(
                "Error",
                isPresented: $viewModel.invalidInviteAlertIsShowing,
                actions: {
                    Button("OK") { }
                }, message: {
                    Text(viewModel.invalidInviteAlertText)
                }
            )
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText,
                tryAgainAction: { await viewModel.getHostedShows() }
            )
            .task {
                await viewModel.getHostedShows()
            }
            .onChange(of: viewModel.showInviteSentSuccessfully) { showInviteSentSuccessfully in
                if showInviteSentSuccessfully {
                    dismiss()
                }
            }
        }
    }
}

struct SendShowInviteView_Previews: PreviewProvider {
    static var previews: some View {
        SendShowInviteView(band: Band.example)
    }
}
