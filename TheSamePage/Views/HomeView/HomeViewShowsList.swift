//
//  NearbyShowsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import SwiftUI

struct HomeViewShowsList: View {
    @ObservedObject var viewModel: HomeViewModel
    
    @Binding var filterConfirmationDialogIsShowing: Bool
    
    var body: some View {
        List {
            Section(viewModel.nearbyShowsListHeaderText) {
                ForEach(viewModel.nearbyShows, id: \.document) { result in
                    let show = result.document!
                    
                    NavigationLink {
                        ShowDetailsView(show: show)
                    } label: {
                        MyShowRow(index: 0, viewModel: MyShowsViewModel())
                    }
                }
            }
        }
        .listStyle(.grouped)
        .refreshable {
            do {
                try await viewModel.fetchNearbyShows()
            } catch {
                print(error)
            }
        }
    }
}

struct NearbyShowsList_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewShowsList(viewModel: HomeViewModel(), filterConfirmationDialogIsShowing: .constant(false))
    }
}
