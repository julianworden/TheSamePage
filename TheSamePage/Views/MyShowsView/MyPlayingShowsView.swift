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
            if !viewModel.playingShows.isEmpty {
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
            } else {
                Text("You're not playing any shows.")
                    .font(.body.italic())
                    .padding(.vertical)
            }
        }
        .task {
            do {
                try await viewModel.getPlayingShows()
            } catch {
                print(error)
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
