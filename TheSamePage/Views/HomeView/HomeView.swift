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
                BackgroundColor()
                
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
                        .italic()
                        .multilineTextAlignment(.center)

                case .error:
                    EmptyView()
                default:
                    ErrorMessage(message: ErrorMessageConstants.invalidViewState)
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
                Button("10 Miles") {
                    Task {
                        await viewModel.changeSearchRadius(toValueInMiles: 10)
                    }
                }
                Button("25 Miles (Default)") {
                    Task {
                        await viewModel.changeSearchRadius(toValueInMiles: 25)
                    }
                }
                Button("50 Miles") {
                    Task {
                        await viewModel.changeSearchRadius(toValueInMiles: 50)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .errorAlert(
                isPresented: $viewModel.errorMessageIsShowing,
                message: viewModel.errorMessageText,
                tryAgainAction: viewModel.fetchNearbyShows
            )
            .task {                
                viewModel.viewState = .dataLoading
                viewModel.addLocationNotificationObserver()
                LocationController.shared.startLocationServices()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel())
    }
}
