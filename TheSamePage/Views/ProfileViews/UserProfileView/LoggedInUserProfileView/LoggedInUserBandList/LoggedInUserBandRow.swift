//
//  LoggedInUserBandRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct LoggedInUserBandRow: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @State private var leaveBandConfirmationAlertIsShowing = false
    
    let index: Int
    
    var body: some View {
        if loggedInUserController.bands.indices.contains(index),
           let loggedInUser = loggedInUserController.loggedInUser {
            let band = loggedInUserController.bands[index]
            
            HStack {
                ListRowElements(
                    title: band.name,
                    subtitle: "\(band.city), \(band.state)",
                    iconName: "band"
                )

                Spacer()


                if !band.loggedInUserIsBandAdmin {
                    Button(role: .destructive) {
                        leaveBandConfirmationAlertIsShowing.toggle()
                    } label: {
                        Text("Leave Band")
                    }
                    .alert(
                        "Are You Sure?",
                        isPresented: $leaveBandConfirmationAlertIsShowing,
                        actions: {
                            Button("Cancel", role: .cancel) { }
                            Button("Yes", role: .destructive) {
                                Task {
                                    await loggedInUserController.removeUserFromBand(remove: loggedInUser, from: band)
                                    await loggedInUserController.getLoggedInUserBands()
                                    await loggedInUserController.getLoggedInUserInfo()
                                }
                            }
                        },
                        message: { Text("If you leave \(band.name), you will no longer be able to access chats and private data for shows in which \(band.name) is a participant.") }
                    )
                }
            }
        }
    }
}

struct LoggedInUserBandRow_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserBandRow(index: 0)
    }
}
