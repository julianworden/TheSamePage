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

    init(band: Band? = nil, showParticipant: ShowParticipant? = nil, isPresentedModally: Bool = false) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band, showParticipant: showParticipant, isPresentedModally: isPresentedModally))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()
                
            case .dataLoaded:
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
                    .sheet(isPresented: $viewModel.addEditBandSheetIsShowing) {
                        NavigationStack {
                            AddEditBandView(bandToEdit: band)
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if band.loggedInUserIsNotInvolvedWithBand {
                                Button {
                                    viewModel.sendShowInviteViewIsShowing.toggle()
                                } label: {
                                    Image(systemName: "envelope")
                                }
                                .sheet(isPresented: $viewModel.sendShowInviteViewIsShowing) {
                                    NavigationStack {
                                        SendShowInviteView(band: band)
                                    }
                                }
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            if band.loggedInUserIsBandAdmin {
                                Button {
                                    viewModel.bandSettingsViewIsShowing.toggle()
                                } label: {
                                    Label("Band settings", systemImage: "gear")
                                }
                                .fullScreenCover(
                                    isPresented: $viewModel.bandSettingsViewIsShowing,
                                    onDismiss: {
                                        Task {
                                            await viewModel.getLatestBandData()
                                        }
                                    },
                                    content: {
                                        BandSettingsView(band: band)
                                    }
                                )
                            }
                        }
                    }
                }
                
            case .error:
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
