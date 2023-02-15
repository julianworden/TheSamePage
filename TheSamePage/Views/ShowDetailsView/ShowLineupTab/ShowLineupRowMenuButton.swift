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
        if let show = viewModel.show {
            ZStack {
                Menu {
                    if show.loggedInUserIsShowHost {
                        Button {
                            viewModel.showParticipantToEdit = showParticipant
                        } label: {
                            Label("Edit Set Time", systemImage: "square.and.pencil")
                        }
                    }

                    Button(role: .destructive) {
                        removeShowParticipantConfirmationAlertIsShowing.toggle()
                    } label: {
                        if show.loggedInUserIsShowHost {
                            Label("Remove Band from Lineup", systemImage: "trash")
                        } else if showParticipant.bandAdminIsLoggedInUser {
                            Label("Leave Show", systemImage: "figure.walk")
                        }
                    }
                } label: {
                    EllipsesMenuIcon()
                }
                .buttonStyle(.bordered)
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
            }
        }
    }
}

struct ShowLineupRowMenu_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupRowMenuButton(viewModel: ShowDetailsViewModel(show: Show.example), showParticipant: ShowParticipant.example)
    }
}
