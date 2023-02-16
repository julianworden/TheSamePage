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
        List {
            Section(viewModel.fetchedShowsListHeaderText) {
                ForEach(viewModel.fetchedShows) { show in
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
    }
}

struct NearbyShowsList_Previews: PreviewProvider {
    static var previews: some View {
        FindShowList(viewModel: FindShowsViewModel())
    }
}
