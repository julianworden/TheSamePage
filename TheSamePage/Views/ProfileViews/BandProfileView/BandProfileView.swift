//
//  BandProfileAdminView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

// TODO: Allow for the band admin to add their own bands to any of their hosted shows

struct BandProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: BandProfileViewModel
    
    @State private var addEditBandSheetIsShowing = false

    init(band: Band? = nil, showParticipant: ShowParticipant? = nil) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band, showParticipant: showParticipant))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()
                
            case .dataLoaded:
                // TODO: Pass this band to each tab so they don't have to have their own if let band statements
                if let band = viewModel.band {
                    ScrollView {
                        BandProfileHeader(viewModel: viewModel)
                        
                        Picker("Select a tab", selection: $viewModel.selectedTab) {
                            ForEach(SelectedBandProfileTab.allCases) { tab in
                                Text(tab.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
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
                    .sheet(isPresented: $addEditBandSheetIsShowing) {
                        NavigationView {
                            AddEditBandView(bandToEdit: band)
                        }
                        .navigationViewStyle(.stack)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if band.loggedInUserIsInvolvedWithBand {
                                NavigationLink {
                                    BandSettingsView(band: band)
                                } label: {
                                    Label("Band settings", systemImage: "gear")
                                }
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
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            okButtonAction: { dismiss() }
        )
        .task {
            await viewModel.callOnAppearMethods()
        }
        .onDisappear {
            viewModel.removeListeners()
        }
    }
}

struct BandProfileAdminView_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileView(band: Band.example)
    }
}
