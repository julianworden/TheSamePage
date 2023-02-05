//
//  LeadingBandsAndShowsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/30/23.
//

import SwiftUI

struct LeadingBandsAndShowsList: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    var body: some View {
        List {
            if !loggedInUserController.upcomingHostedShows.isEmpty {
                Section {
                    ForEach(loggedInUserController.hostedShows) { show in
                        NavigationLink {
                            ShowDetailsView(show: show)
                        } label: {
                            Text(show.name)
                        }
                    }
                } header: {
                    Text("Shows you're hosting")
                } footer: {
                    Text(ErrorMessageConstants.userIsStillHostingUpcomingShowsAndCannotDeleteAccount)
                }
            }

            if !loggedInUserController.adminBands.isEmpty {
                Section {
                    ForEach(loggedInUserController.adminBands) { band in
                        NavigationLink {
                            BandProfileView(band: band)
                        } label: {
                            Text(band.name)
                        }
                    }
                } header: {
                    Text("Bands you're leading")
                } footer: {
                    Text(ErrorMessageConstants.userIsStillBandAdminAndCannotDeleteAccount)
                }
            }
        }
    }
}

struct LeadingBandsAndShowsList_Previews: PreviewProvider {
    static var previews: some View {
        LeadingBandsAndShowsList()
    }
}
