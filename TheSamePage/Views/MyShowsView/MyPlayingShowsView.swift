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
            switch viewModel.state {
            case .dataLoading:
                ProgressView()
            case .dataLoaded:
                ScrollView {
                    ForEach(viewModel.playingShows) { show in
                        NavigationLink {
                            ShowDetailsView(show: show)
                        } label: {
                            LargeListRow(show: show, joinedShow: nil)
                        }
                        .foregroundColor(.black)
                    }
                }
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
                viewModel.state = .error(message: error.localizedDescription)
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
