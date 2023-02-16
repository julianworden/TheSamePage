//
//  HomeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct FindShowsView: View {
    @StateObject var viewModel = FindShowsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundColor()
                
                switch viewModel.viewState {
                case .dataLoading:
                    ProgressView()
                    
                case .dataLoaded:
                    FindShowList(viewModel: viewModel)
                    
                case .dataNotFound:
                    Text(viewModel.noDataFoundText)
                        .multilineTextAlignment(.center)

                case .error:
                    EmptyView()
                default:
                    ErrorMessage(message: ErrorMessageConstants.invalidViewState)
                }
            }
            .navigationTitle("Find Shows")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Menu {
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
                        } label: {
                            Label("Filter by Distance", systemImage: "mappin")
                        }

                        Menu {
                            ForEach(UsState.allCases, id: \.self) { state in
                                Button(state.rawValue) {
                                    Task {
                                        await viewModel.fetchShows(in: state.rawValue)
                                    }
                                }
                            }
                        } label: {
                            Label("Filter by State", systemImage: "globe")
                        }
                    } label: {
                        Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                    }
                }
            }
            .errorAlert(
                isPresented: $viewModel.errorMessageIsShowing,
                message: viewModel.errorMessageText,
                tryAgainAction: viewModel.fetchNearbyShows
            )
            .task {
                // Keeps the search parameters from resetting every time this view is shown.
                if !viewModel.isSearchingByState && !viewModel.isSearchingByState {
                    viewModel.viewState = .dataLoading
                    viewModel.addLocationNotificationObserver()
                    LocationController.shared.startLocationServices()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        FindShowsView(viewModel: FindShowsViewModel())
    }
}
