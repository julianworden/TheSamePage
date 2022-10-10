//
//  ShowLineupList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

struct ShowLineupList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    init(viewModel: ShowDetailsViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(zip(viewModel.showLineup.indices, viewModel.showLineup)), id: \.0) { rowIndex, showParticipant in
                NavigationLink {
                    BandProfileRootView(band: nil, showParticipant: showParticipant)
                } label: {                        
                    SmallListRow(title: showParticipant.name, subtitle: nil, iconName: "band", displayChevron: true, rowIndex: rowIndex, listItemCount: viewModel.showLineup.count)
                        .padding(.horizontal)
                }
                .tint(.black)
            }
        }
    }
}

struct ShowLineupList_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
