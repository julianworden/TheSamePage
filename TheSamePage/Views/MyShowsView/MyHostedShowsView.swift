//
//  MyHostedShowsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/9/22.
//

import SwiftUI

struct MyHostedShowsView: View {
    @ObservedObject var viewModel: MyShowsViewModel
    
    var body: some View {
        Group {
            switch viewModel.myHostedShowsViewState {
            case .dataLoading:
                ProgressView()

            case .dataLoaded, .error:
                List {
                    Section("Upcoming shows You're Hosting") {
                        ForEach(Array(viewModel.upcomingHostedShows.enumerated()), id: \.element) { index, show in
                            NavigationLink {
                                ShowDetailsView(show: show)
                            } label: {
                                HostedShowRow(index: index, viewModel: viewModel)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.getHostedShows()
                }

            case .dataNotFound:
                VStack {
                    NoDataFoundMessageWithButtonView(
                        isPresentingSheet: $viewModel.addEditShowSheetIsShowing,
                        shouldDisplayButton: true,
                        buttonText: "Create Show",
                        buttonImageName: "plus",
                        message: "You're not hosting any upcoming shows."
                    )
                }
                
            default:
                ErrorMessage(message: ErrorMessageConstants.invalidViewState)
            }
        }
        .errorAlert(
            isPresented: $viewModel.myHostedShowsErrorAlertIsShowing,
            message: viewModel.myHostedShowsErrorAlertText,
            tryAgainAction: {
                await viewModel.getHostedShows()
            }
        )
        .task {
            await viewModel.getHostedShows()
        }
    }
}

struct MyHostedShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyHostedShowsView(viewModel: MyShowsViewModel())
    }
}
