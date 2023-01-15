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
                
            case .dataLoaded:
                List {
                    Section("You're playing...") {
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
                .listStyle(.grouped)
                
            case .dataNotFound:
                Text("You're not playing any shows.")
                    .font(.body.italic())
                    .padding(.vertical)
                
            case .error:
                EmptyView()
                
            default:
                ErrorMessage(message: "Unknown ViewState given in MyPlayingShowsView.")
            }
        }
        .errorAlert(
            isPresented: $viewModel.myPlayingShowsErrorAlertIsShowing,
            message: viewModel.myPlayingShowsErrorAlertText,
            tryAgainAction: {
                viewModel.getPlayingShows()
            }
        )
        .task {
            viewModel.getPlayingShows()
        }
        .onDisappear {
            viewModel.removePlayingShowsListener()
        }
    }
}

struct MyPlayingShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlayingShowsView(viewModel: MyShowsViewModel())
    }
}
