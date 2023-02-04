//
//  LoggedInUserBandMenuButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/2/23.
//

import SwiftUI

struct LoggedInUserBandMenuButton: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @State private var leaveBandConfirmationAlertIsShowing = false

    let band: Band

    var body: some View {
        if let loggedInUser = loggedInUserController.loggedInUser {
            Menu {
                Button(role: .destructive) {
                    leaveBandConfirmationAlertIsShowing.toggle()
                } label: {
                    Label("Leave Band", systemImage: "figure.walk")
                }
            } label: {
                EllipsesMenuIcon()
            }
            .alert(
                "Are You Sure?",
                isPresented: $leaveBandConfirmationAlertIsShowing,
                actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        Task {
                            await loggedInUserController.removeUserFromBand(remove: loggedInUser, from: band)
                            await loggedInUserController.getLoggedInUserPlayingBands()
                            await loggedInUserController.getLoggedInUserInfo()
                        }
                    }
                },
                message: { Text("If you leave \(band.name), you will no longer be able to access chats and private data for shows in which \(band.name) is a participant.") }
            )
        }
    }
}

struct LoggedInUserBandButton_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserBandMenuButton(band: Band.example)
    }
}
