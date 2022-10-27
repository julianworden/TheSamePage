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
                                // TODO: FIX INDEX
                                PlayingShowRow(index: index, viewModel: viewModel)
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
                .listStyle(.grouped)
            case .dataNotFound:
                Text("You're not playing any shows.")
                    .font(.body.italic())
                    .padding(.vertical)
            case .error(let error):
                ErrorMessage(
                    message: "Failed to fetch your shows. Please check your internet connection and relaunch the app.",
                    errorText: error
                )
            }
        }
        .task {
            do {
                try await viewModel.getPlayingShows()
            } catch {
                viewModel.myPlayingShowsViewState = .error(message: error.localizedDescription)
            }
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
