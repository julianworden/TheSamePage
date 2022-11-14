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
    
    @State private var addEditBandSheetIsShowing = false

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
            }
        }
        .navigationTitle("Band Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    addEditBandSheetIsShowing = true
                }
            }
        }
    }
}

struct BandProfileAdminView_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileView(band: Band.example)
    }
}
