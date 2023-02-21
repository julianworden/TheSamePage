//
//  BandProfileAdminView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct BandProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: BandProfileViewModel
    @StateObject var sheetNavigator = BandProfileViewSheetNavigator()

    init(
        band: Band?,
        showParticipant: ShowParticipant? = nil,
        bandId: String? = nil,
        isPresentedModally: Bool = false
    ) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band, showParticipant: showParticipant, bandId: bandId, isPresentedModally: isPresentedModally))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()
                
            case .dataLoaded, .error:
                if let band = viewModel.band {
                    ScrollView {
                        VStack {
                            BandProfileHeader(viewModel: viewModel)

                            Picker("Select a tab", selection: $viewModel.selectedTab) {
                                ForEach(SelectedBandProfileTab.allCases) { tab in
                                    Text(tab.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)

                            switch viewModel.selectedTab {
                            case .about:
                                BandAboutTab(viewModel: viewModel)
                            case .members:
                                BandMembersTab(viewModel: viewModel)
                            case .links:
                                LinkTab(viewModel: viewModel)
                            case .shows:
                                BandShowsTab(viewModel: viewModel)
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if viewModel.shouldShowMenu {
                                Menu {
                                    if band.loggedInUserIsNotInvolvedWithBand {
                                        Button {
                                            sheetNavigator.sheetDestination = .sendShowInviteView(band: band)
                                        } label: {
                                            Label("Send Show Invite", systemImage: "envelope")
                                        }
                                    }

                                    if let shortenedDynamicLink = viewModel.shortenedDynamicLink {
                                        ShareLink(item: shortenedDynamicLink) {
                                            Label("Share", systemImage: "square.and.arrow.up")
                                        }
                                    }

                                    if band.loggedInUserIsBandAdmin {
                                        Button {
                                            sheetNavigator.sheetDestination = .bandSettingsView(band: band)
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
                                            await viewModel.getLatestBandData()
                                        }
                                    },
                                    content: {
                                        sheetNavigator.sheetView()
                                    }
                                )
                            }
                        }
                    }
                }

            case .dataDeleted:
                EmptyView()
                
            default:
                ErrorMessage(message: "Unknown viewState provided")
            }
        }
        .navigationTitle("Band Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isPresentedModally {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            okButtonAction: { dismiss() }
        )
        .task {
            await viewModel.callOnAppearMethods()
        }
        .onChange(of: viewModel.bandWasDeleted) { bandWasDeleted in
            if bandWasDeleted {
                dismiss()
            }
        }
    }
}

struct BandProfileAdminView_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileView(band: Band.example)
    }
}
