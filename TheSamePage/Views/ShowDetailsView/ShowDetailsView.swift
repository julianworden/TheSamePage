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

    init(show: Show?, showId: String? = nil, isPresentedModally: Bool = false) {
        _viewModel = StateObject(wrappedValue: ShowDetailsViewModel(show: show, showId: showId, isPresentedModally: isPresentedModally))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()

            if let show = viewModel.show {
                switch viewModel.viewState {
                case .dataLoading:
                    ProgressView()

                case .dataLoaded, .displayingView, .error:
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
                                ShowLocationTab(viewModel: viewModel, show: show)
                            case .details:
                                ShowDetailsTab(viewModel: viewModel)
                            }
                        }
                    }

                default:
                    ErrorMessage(message: ErrorMessageConstants.invalidViewState)
                }
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
                if let show = viewModel.show {
                    if show.loggedInUserIsInvolvedInShow {
                        Button {
                            viewModel.conversationViewIsShowing.toggle()
                        } label: {
                            Image(systemName: "bubble.right")
                        }
                        .fullScreenCover(isPresented: $viewModel.conversationViewIsShowing) {
                            NavigationStack {
                                ConversationView(
                                    show: show,
                                    chatParticipantUids: show.participantUids
                                )
                            }
                        }
                    } else if show.loggedInUserIsNotInvolvedInShow && !show.alreadyHappened {
                        Button {
                            viewModel.showApplicationSheetIsShowing.toggle()
                        } label: {
                            Label("Play This Show", systemImage: "pencil.and.ellipsis.rectangle")
                        }
                        .sheet(isPresented: $viewModel.showApplicationSheetIsShowing) {
                            SendShowApplicationView(show: show)
                        }
                    }
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if let show = viewModel.show {
                    if show.loggedInUserIsShowHost {
                        Button {
                            viewModel.showSettingsViewIsShowing.toggle()
                        } label: {
                            Image(systemName: "gear")
                        }
                        .fullScreenCover(
                            isPresented: $viewModel.showSettingsViewIsShowing,
                            onDismiss: {
                                Task {
                                    await viewModel.getLatestShowData()
                                }
                            },
                            content: {
                                ShowSettingsView(show: show)
                            }
                        )
                    }
                }
            }
        }
        .errorAlert(isPresented: $viewModel.errorAlertIsShowing, message: viewModel.errorAlertText)
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
        NavigationStack {
            ShowDetailsView(show: Show.example)
        }
    }
}
