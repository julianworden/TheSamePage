//
//  HomeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    @State private var filterConfirmationDialogIsShowing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                switch viewModel.state {
                case .dataLoading:
                    ProgressView()
                    
                case .dataLoaded:
                    NearbyShowsList(
                        viewModel: viewModel,
                        filterConfirmationDialogIsShowing: $filterConfirmationDialogIsShowing
                    )
                    
                case .dataNotFound:
                    Text("We can't find any shows near you, try widening your search radius with the filter button!")
                    
                case .error(let message):
                    ErrorMessage(
                        message: "Failed to fetch shows near you. Please use Settings to ensure that location services are enabled for The Same Page, check your internet connection, and restart the app.",
                        errorText: message)
                }
            }
            .navigationTitle("Shows Near You")
            .toolbar {
                ToolbarItem {
                    Button {
                        filterConfirmationDialogIsShowing = true
                    } label: {
                        Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
            }
            .confirmationDialog("Select a search radius", isPresented: $filterConfirmationDialogIsShowing) {
                Button("10 Miles") { viewModel.changeSearchRadius(toValue: 10) }
                Button("25 Miles (Default)") { viewModel.changeSearchRadius(toValue: 25) }
                Button("50 Miles") { viewModel.changeSearchRadius(toValue: 50) }
                Button("Cancel", role: .cancel) { }
            }
            .task {
                if viewModel.nearbyShows.isEmpty {
                    viewModel.state = .dataLoading
                    do {
                        try await viewModel.fetchNearbyShows()
                    } catch {
                        print(error)
                    }
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
