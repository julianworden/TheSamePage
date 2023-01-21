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
                Button {
                    viewModel.showDetailsViewIsShowing.toggle()
                } label: {
                    BandShowRow(viewModel: viewModel, index: index)
                }
                .fullScreenCover(isPresented: $viewModel.showDetailsViewIsShowing) {
                    NavigationView {
                        ShowDetailsView(show: show, isPresentedModally: true)
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
