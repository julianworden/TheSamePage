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
        VStack(spacing: 0) {
            ForEach(viewModel.showLineup) { showParticipant in
                NavigationLink {
                    BandProfileRootView(band: nil, showParticipant: showParticipant)
                } label: {                        
                    SmallListRow(title: showParticipant.name, subtitle: nil, iconName: "band", displayChevron: true)
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
