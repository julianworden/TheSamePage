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

            case .dataLoaded:
                List {
                    Section("You're hosting...") {
                        ForEach(Array(viewModel.hostedShows.enumerated()), id: \.element) { index, show in
                            NavigationLink {
                                ShowDetailsView(show: show)
                            } label: {
                                HostedShowRow(index: index, viewModel: viewModel)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .listStyle(.grouped)

            case .dataNotFound:
                VStack {
                    NoDataFoundMessageWithButtonView(
                        isPresentingSheet: $viewModel.addEditShowSheetIsShowing,
                        shouldDisplayButton: true,
                        buttonText: "Create Show",
                        buttonImageName: "plus",
                        message: "You're not hosting any shows"
                    )
                }
                
            case .error:
                EmptyView()
                
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
