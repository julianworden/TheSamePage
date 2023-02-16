//
//  MyPlayingShowsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/9/22.
//

import SwiftUI

struct MyPlayingShowsView: View {
    @ObservedObject var viewModel: MyShowsViewModel
    
    var body: some View {
        Group {
            switch viewModel.myPlayingShowsViewState {
            case .dataLoading:
                ProgressView()
                
            case .dataLoaded, .error:
                List {
                    Section("Shows You're Playing") {
                        ForEach(Array(viewModel.playingShows.enumerated()), id: \.element) { index, show in
                            NavigationLink {
                                ShowDetailsView(show: show)
                            } label: {
                                PlayingShowRow(index: index, viewModel: viewModel)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                
            case .dataNotFound:
                NoDataFoundMessage(message: "You're not playing any shows.")

            default:
                ErrorMessage(message: "Unknown ViewState given in MyPlayingShowsView.")
            }
        }
        .errorAlert(
            isPresented: $viewModel.myPlayingShowsErrorAlertIsShowing,
            message: viewModel.myPlayingShowsErrorAlertText,
            tryAgainAction: { await viewModel.getPlayingShows() }
        )
        .task {
            await viewModel.getPlayingShows()
        }
    }
}

struct MyPlayingShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlayingShowsView(viewModel: MyShowsViewModel())
    }
}
