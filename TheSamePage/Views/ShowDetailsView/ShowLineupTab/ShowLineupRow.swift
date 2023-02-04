//
//  ShowLineupRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/26/22.
//

import SwiftUI

struct ShowLineupRow: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    let index: Int
    
    var body: some View {
        if viewModel.showParticipants.indices.contains(index) {
            let showParticipant = viewModel.showParticipants[index]

            ListRowElements(
                title: showParticipant.name,
                iconName: "band"
            )
        }
    }
}

struct ShowLineupRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupRow(viewModel: ShowDetailsViewModel(show: Show.example), index: 0)
    }
}
