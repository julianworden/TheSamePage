//
//  BandShowRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct BandShowRow: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    let index: Int
    
    var body: some View {
        let show = viewModel.bandShows[index]
        
        ListRowElements(
            title: show.name,
            subtitle: "At \(show.venue) on \(show.formattedDate)",
            iconName: "stage",
            displayDivider: true
        )
        .foregroundColor(show.date.unixDateAsDate < Date.now ? .secondary : .primary)
    }
}

struct BandShowRow_Previews: PreviewProvider {
    static var previews: some View {
        BandShowRow(viewModel: BandProfileViewModel(band: Band.example), index: 0)
    }
}
