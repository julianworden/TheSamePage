//
//  NearbyShowsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import SwiftUI
import Typesense

struct FindShowList: View {
    @ObservedObject var viewModel: FindShowsViewModel

    var body: some View {
        if viewModel.userHasGivenLocationPermission || viewModel.isSearchingByState {
            List {
                Section(viewModel.fetchedShowsListHeaderText) {
                    ForEach(viewModel.upcomingFetchedShows) { show in
                        NavigationLink {
                            ShowDetailsView(show: show)
                        } label: {
                            FindShowsListRow(show: show)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable {
                await viewModel.fetchNearbyShows()
            }
        } else if !viewModel.userHasGivenLocationPermission {
            VStack {
                NoDataFoundMessage(message: "You've denied location permissions for The Same Page. Although you can still search for shows by state, you cannot search for shows that are near your current location. If you'd like, you can give The Same Page permission to access your location by using your phone's Settings.")
                
                Button {
                    let openSettingsUrlString = UIApplication.openSettingsURLString
                    if let openSettingsUrl = URL(string: openSettingsUrlString) {
                        UIApplication.shared.open(openSettingsUrl)
                    }
                } label: {
                    Label("Go to Settings", systemImage: "gear")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        } else {
            Text("Hello")
        }
    }
}

struct NearbyShowsList_Previews: PreviewProvider {
    static var previews: some View {
        FindShowList(viewModel: FindShowsViewModel())
    }
}
