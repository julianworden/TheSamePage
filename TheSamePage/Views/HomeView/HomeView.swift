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
                
                switch viewModel.viewState {
                case .dataLoading:
                    ProgressView()
                    
                case .dataLoaded:
                    HomeViewShowsList(
                        viewModel: viewModel,
                        filterConfirmationDialogIsShowing: $viewModel.filterConfirmationDialogIsShowing
                    )
                    
                case .dataNotFound:
                    Text("We can't find any shows near you, try widening your search radius with the filter button!")
                    
                case .error(let message):
                    ErrorMessage(
                        message: ErrorMessageConstants.somethingWentWrong,
                        systemErrorText: message)
                    
                default:
                    ErrorMessage(message: ErrorMessageConstants.unknownViewState)
                }
            }
            .navigationTitle("Shows Near You")
            .toolbar {
                ToolbarItem {
                    Button {
                        viewModel.filterConfirmationDialogIsShowing = true
                    } label: {
                        Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
            }
            .confirmationDialog("Select a search radius", isPresented: $viewModel.filterConfirmationDialogIsShowing) {
                Button("10 Miles") { viewModel.changeSearchRadius(toValue: 10) }
                Button("25 Miles (Default)") { viewModel.changeSearchRadius(toValue: 25) }
                Button("50 Miles") { viewModel.changeSearchRadius(toValue: 50) }
                Button("Cancel", role: .cancel) { }
            }
            .onAppear {
                if viewModel.nearbyShows.isEmpty {
                    viewModel.viewState = .dataLoading
                    viewModel.fetchNearbyShows()
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
