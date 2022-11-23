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
                    Text("You're not hosting any shows.")
                        .font(.body.italic())

                    NavigationLink {
                        AddEditShowView(showToEdit: nil)
                    } label: {
                        Text("Tap here to create a show.")
                            .italic()
                    }
                }
                .padding(.top)
                
            case .error:
                EmptyView()
                
            default:
                ErrorMessage(message: ErrorMessageConstants.unknownViewState)
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
