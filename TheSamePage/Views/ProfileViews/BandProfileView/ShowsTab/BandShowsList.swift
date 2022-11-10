//
//  BandShowsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct BandShowsList: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(viewModel.bandShows.enumerated()), id: \.element) { index, show in
                NavigationLink {
                    ShowDetailsView(show: show)
                } label: {
                    BandShowRow(viewModel: viewModel, index: index)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct BandShowsList_Previews: PreviewProvider {
    static var previews: some View {
        BandShowsList(viewModel: BandProfileViewModel(band: Band.example))
    }
}
