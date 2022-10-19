//
//  NearbyShowsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/19/22.
//

import SwiftUI

struct NearbyShowsList: View {
    @ObservedObject var viewModel: HomeViewModel
    
    @Binding var filterConfirmationDialogIsShowing: Bool
    
    var body: some View {
        List {
            Section(viewModel.nearbyShowsListHeaderText) {
                ForEach(viewModel.nearbyShows) { show in
                    NavigationLink {
                        ShowDetailsView(show: show)
                    } label: {
                        LargeListRow(show: show, joinedShow: nil)
                    }
                }
            }
        }
        .listStyle(.grouped)
        .toolbar {
            ToolbarItem {
                Button {
                    filterConfirmationDialogIsShowing = true
                } label: {
                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                }
            }
        }
        .refreshable {
            await viewModel.performShowsGeoQuery()
        }
        .animation(.default, value: viewModel.nearbyShows)
    }
}

struct NearbyShowsList_Previews: PreviewProvider {
    static var previews: some View {
        NearbyShowsList(viewModel: HomeViewModel(), filterConfirmationDialogIsShowing: .constant(false))
    }
}
