//
//  LoggedInUserBandsTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/18/23.
//

import SwiftUI

struct LoggedInUserBandsTab: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @State private var createBandSheetIsShowing = false

    var body: some View {
        ZStack {
            if !loggedInUserController.allBands.isEmpty {
                VStack {
                    LoggedInUserBandList()

                    Button {
                        createBandSheetIsShowing.toggle()
                    } label: {
                        Label("Create Band", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                }
            } else if loggedInUserController.playingBands.isEmpty {
                NoDataFoundMessageWithButtonView(
                    isPresentingSheet: $createBandSheetIsShowing,
                    shouldDisplayButton: true,
                    buttonText: "Create Band",
                    buttonImageName: "plus",
                    message: "You are not a member of any bands."
                )
            }
        }
        .fullScreenCover(
            isPresented: $createBandSheetIsShowing,
            onDismiss: {
                Task {
                    await loggedInUserController.getLoggedInUserAllBands()
                }
            },
            content: {
                AddEditBandView(bandToEdit: nil, isPresentedModally: true)
            }
        )
    }
}

struct LoggedInUserBandsTab_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserBandsTab()
    }
}
