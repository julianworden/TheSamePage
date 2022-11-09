//
//  BandProfileAdminView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

// TODO: Allow for the band admin to add their own bands to any of their hosted shows

struct BandProfileView: View {
    @StateObject var viewModel: BandProfileViewModel

    init(band: Band? = nil, showParticipant: ShowParticipant? = nil) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band, showParticipant: showParticipant))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if let band = viewModel.band {
                ScrollView {
                    BandProfileHeader(viewModel: viewModel)
                    
                    if band.loggedInUserIsBandAdmin {
                        NavigationLink {
                            SendShowInviteView(band: band)
                        } label: {
                            Label("Invite to Show", systemImage: "envelope")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Picker("Select a tab", selection: $viewModel.selectedTab) {
                        ForEach(SelectedBandProfileTab.allCases) { tab in
                            Text(tab.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    switch viewModel.selectedTab {
                    case .members:
                        BandMembersTab(viewModel: viewModel)
                    case .links:
                        LinkTab(viewModel: viewModel)
                    case .shows:
                        BandShowsTab(viewModel: viewModel)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationTitle("Band Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BandProfileAdminView_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileView(band: Band.example)
    }
}
