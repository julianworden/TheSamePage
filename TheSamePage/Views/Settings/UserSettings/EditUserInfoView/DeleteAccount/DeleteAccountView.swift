//
//  DeleteAccountView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/30/23.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @ObservedObject var navigationViewModel: UserSettingsNavigationViewModel

    @State private var searchingForHostedShowsAndAdminBands = false

    var body: some View {
        ZStack {
            BackgroundColor()

            if searchingForHostedShowsAndAdminBands {
                ProgressView()
            } else if loggedInUserController.loggedInUserIsNotLeadingAnyUpcomingShowsOrBands {
                DeleteAccountConfirmationView(navigationViewModel: navigationViewModel)
            } else if !loggedInUserController.upcomingHostedShows.isEmpty || !loggedInUserController.adminBands.isEmpty {
                LeadingBandsAndShowsList()
            }
        }
        .errorAlert(
            isPresented: $loggedInUserController.errorMessageShowing,
            message: loggedInUserController.errorMessageText,
            okButtonAction: {
                dismiss()
            }
        )
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            searchingForHostedShowsAndAdminBands = true
            await loggedInUserController.getLoggedInUserAdminBands()
            await loggedInUserController.getLoggedInUserHostedShows()
            searchingForHostedShowsAndAdminBands = false
        }
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView(navigationViewModel: UserSettingsNavigationViewModel())
            .environmentObject(LoggedInUserController())
    }
}
