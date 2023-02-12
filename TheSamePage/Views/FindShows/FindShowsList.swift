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
    
    @Binding var filterConfirmationDialogIsShowing: Bool
    
    var body: some View {
        List {
            Section(viewModel.nearbyShowsListHeaderText) {
                ForEach(viewModel.nearbyShows, id: \.document) { result in
                    let show = result.document!
                    
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
        FindShowList(viewModel: FindShowsViewModel(), filterConfirmationDialogIsShowing: .constant(false))
    }
}
