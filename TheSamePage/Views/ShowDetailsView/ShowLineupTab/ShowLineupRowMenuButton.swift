//
//  ShowLineupRowMenu.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/2/23.
//

import SwiftUI

struct ShowLineupRowMenuButton: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    @State private var leaveShowConfirmationAlertIsShowing = false
    @State private var removeShowParticipantConfirmationAlertIsShowing = false

    let showParticipant: ShowParticipant

    var body: some View {
        if viewModel.show.loggedInUserIsShowHost {
            Menu {
                Button(role: .destructive) {
                    removeShowParticipantConfirmationAlertIsShowing.toggle()
                } label: {
                    Label("Remove Band from Lineup", systemImage: "trash")
                }
            } label: {
                EllipsesMenuIcon()
            }
            .alert(
                "Are You Sure?",
                isPresented: $removeShowParticipantConfirmationAlertIsShowing,
                actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        Task {
                            await viewModel.removeShowParticipantFromShow(showParticipant: showParticipant)
                            await viewModel.getLatestShowData()
                            await viewModel.getShowParticipants()
                        }
                    }
                },
                message: { Text("All of this band's members will lose access to this show's private data and chat.") }
            )
        } else if showParticipant.bandAdminIsLoggedInUser {
            Menu {
                Button(role: .destructive) {
                    leaveShowConfirmationAlertIsShowing.toggle()
                } label: {
                    Label("Leave Show", systemImage: "figure.walk")
                }
            } label: {
                EllipsesMenuIcon()
            }
            .alert(
                "Are You Sure?",
                isPresented: $leaveShowConfirmationAlertIsShowing,
                actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        Task {
                            await viewModel.removeShowParticipantFromShow(showParticipant: showParticipant)
                            await viewModel.getLatestShowData()
                            await viewModel.getShowParticipants()
                        }
                    }
                },
                message: { Text("If you leave this show, you will no longer have access to its private info or its chat. You will not be able to join the show again unless the show's host invites you.") }
            )
        }
    }
}

struct ShowLineupRowMenu_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupRowMenuButton(viewModel: ShowDetailsViewModel(show: Show.example), showParticipant: ShowParticipant.example)
    }
}
