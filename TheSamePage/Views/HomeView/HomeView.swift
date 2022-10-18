//
//  HomeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        if !viewModel.nearbyShows.isEmpty {
                            ForEach(viewModel.nearbyShows) { show in
                                LargeListRow(show: show, joinedShow: nil)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Shows Near You")
            .task {
                do {
                    try await viewModel.performShowsGeoQuery()
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}
