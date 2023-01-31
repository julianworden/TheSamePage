//
//  ShowLineupList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

struct ShowLineupList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(viewModel.showParticipants.enumerated()), id: \.element) { index, showParticipant in
                NavigationLink {
                    BandProfileView(showParticipant: showParticipant)
                } label: {
                    ShowLineupRow(viewModel: viewModel, index: index)
                }
                .tint(.primary)

                Divider()
            }
        }
    }
}

struct ShowLineupList_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
