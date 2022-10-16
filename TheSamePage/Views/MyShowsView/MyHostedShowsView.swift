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
            switch viewModel.state {
            case .dataLoading:
                ProgressView()
            case .dataLoaded:
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.hostedShows) { show in
                            NavigationLink {
                                ShowDetailsView(show: show)
                            } label: {
                                LargeListRow(show: show, joinedShow: nil)
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
            case .dataNotFound:
                VStack {
                    Text("You're not hosting any shows.")
                        .font(.body.italic())
                    
                    NavigationLink {
                        AddEditShowView(viewTitleText: "Create Show", showToEdit: nil)
                    } label: {
                        Text("Tap here to create a show.")
                            .italic()
                    }
                }
                .padding(.top)
            case .error(let message):
                ErrorMessage(
                    message: "Failed to fetch your hosted shows. Please check your internet connection and relaunch the app.",
                    errorText: message
                )
            }
        }
        .task {
            do {
                try await viewModel.getHostedShows()
            } catch {
                viewModel.state = .error(message: error.localizedDescription)
            }
        }
        .onDisappear {
            viewModel.removeHostedShowsListener()
        }
    }
}

struct MyHostedShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyHostedShowsView(viewModel: MyShowsViewModel())
    }
}
