//
//  ShowDetailsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import SwiftUI

struct ShowDetailsView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel: ShowDetailsViewModel
        
    init(show: Show, isPresentedModally: Bool = false) {
        _viewModel = StateObject(wrappedValue: ShowDetailsViewModel(show: show, isPresentedModally: isPresentedModally))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()
                
            case .dataLoaded:
                ScrollView {
                    VStack(spacing: 10) {
                        ShowDetailsHeader(viewModel: viewModel)

                        Picker("Select View", selection: $viewModel.selectedTab) {
                            ForEach(SelectedShowDetailsTab.allCases) { tabName in
                                Text(tabName.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        switch viewModel.selectedTab {
                        case .lineup:
                            ShowLineupTab(viewModel: viewModel)
                        case .backline:
                            ShowBacklineTab(viewModel: viewModel)
                        case .times:
                            ShowTimeTab(viewModel: viewModel)
                        case .location:
                            ShowLocationTab(viewModel: viewModel)
                        case .details:
                            ShowDetailsTab(viewModel: viewModel)
                        }
                    }
                }

                // TODO: MAke this error handling more uniform with the rest of the app
            case .error(let message):
                ErrorMessage(
                    message: "Failed to fetch details for this show.",
                    systemErrorText: message
                )
                
            default:
                ErrorMessage(message: ErrorMessageConstants.invalidViewState)
            }
        }
        .navigationTitle("Show Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isPresentedModally {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.show.loggedInUserIsInvolvedInShow {
                    // TODO: Make this a NavigationLink instead
                    NavigationLink {
                        ConversationView(
                            show: viewModel.show,
                            showParticipants: viewModel.showParticipants
                        )
                    } label: {
                        Image(systemName: "bubble.right")
                    }
                } else if viewModel.show.loggedInUserIsNotInvolvedInShow {
                    Button {
                        viewModel.showApplicationSheetIsShowing.toggle()
                    } label: {
                        Label("Play This Show", systemImage: "pencil.and.ellipsis.rectangle")
                    }
                    .fullScreenCover(isPresented: $viewModel.showApplicationSheetIsShowing) {
                        NavigationView {
                            // TODO: Fill this in!
                            EmptyView()
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.show.loggedInUserIsShowHost {
                    // TODO: Make this a NavigationLink instead
                    NavigationLink {
                        ShowSettingsView(show: viewModel.show)
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .task {
            await viewModel.callOnAppearMethods()
        }
        .refreshable {
            await viewModel.callOnAppearMethods()
        }
    }
}


// TODO: Figure out why this preview crashes
struct ShowDetailsRootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShowDetailsView(show: Show.example)
        }
    }
}
