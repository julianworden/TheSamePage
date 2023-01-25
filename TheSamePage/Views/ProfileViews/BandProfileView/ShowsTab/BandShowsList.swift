//
//  BandShowsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct BandShowsList: View {
    @ObservedObject var viewModel: BandProfileViewModel

    @State private var selectedShow: Show?
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(viewModel.bandShows.enumerated()), id: \.element) { index, show in
                Button {
                    selectedShow = show
                } label: {
                    BandShowRow(viewModel: viewModel, index: index)
                }
                .fullScreenCover(item: $selectedShow) { selectedShow in
                    NavigationView {
                        ShowDetailsView(show: selectedShow, isPresentedModally: true)
                    }
                }
            }
        }
    }
}

struct BandShowsList_Previews: PreviewProvider {
    static var previews: some View {
        BandShowsList(viewModel: BandProfileViewModel(band: Band.example))
    }
}
