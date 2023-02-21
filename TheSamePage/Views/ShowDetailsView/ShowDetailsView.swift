//
//  ShowDetailsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import SwiftUI

struct ShowDetailsView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: ShowDetailsViewModel
    @StateObject private var sheetNavigator = ShowDetailsViewSheetNavigator()

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

                case .dataDeleted:
                    EmptyView()

                default:
                    ErrorMessage(message: ErrorMessageConstants.invalidViewState)
                }
            }
        }
        .navigationTitle("Show Details")
        .navigationBarTitleDisplayMode(.inline)
        // Tried putting ToolbarContent in separate view, wouldn't build when Menu was included. Don't know why.
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isPresentedModally {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                }
            }

            if viewModel.viewState != .dataDeleted,
               let show = viewModel.show {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.shouldShowMenu {
                        Menu {
                            if show.loggedInUserIsNotInvolvedInShow && !show.alreadyHappened {
                                Button {
                                    sheetNavigator.sheetDestination = .showApplicationView(show: show)
                                } label: {
                                    Label("Play This Show", systemImage: "pencil.and.ellipsis.rectangle")
                                }
                            }

                            if show.loggedInUserIsInvolvedInShow {
                                Button {
                                    sheetNavigator.sheetDestination = .conversationView(
                                        show: show,
                                        chatParticipantUids: show.participantUids
                                    )
                                } label: {
                                    Label("Chat", systemImage: "bubble.right")
                                }
                            }

                            if let shortenedDynamicLink = viewModel.shortenedDynamicLink {
                                ShareLink(item: shortenedDynamicLink) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                            }

                            if show.loggedInUserIsShowHost {
                                Button {
                                    sheetNavigator.sheetDestination = .showSettingsView(show: show)
                                } label: {
                                    Label("Settings", systemImage: "gear")
                                }
                            }
                        } label: {
                            EllipsesMenuIcon()
                        }
                        .fullScreenCover(
                            isPresented: $sheetNavigator.presentSheet,
                            onDismiss: {
                                Task {
                                    await viewModel.getLatestShowData()
                                }
                            },
                            content: {
                                NavigationStack {
                                    sheetNavigator.sheetView()
                                }
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
        .onChange(of: viewModel.showWasCancelled) { showWasCancelled in
            if showWasCancelled {
                dismiss()
            }
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
