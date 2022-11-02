//
//  BassGuitarBacklineList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/22/22.
//

import SwiftUI

struct BassGuitarBacklineList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.bassGuitarBacklineItems) { bassGuitarBacklineItem in
                ShowBacklineRow(title: bassGuitarBacklineItem.name, subtitle: bassGuitarBacklineItem.notes, iconName: "bass guitar")
            }
        }
        .padding(.horizontal)
    }
}

struct BassGuitarBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        BassGuitarBacklineList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
