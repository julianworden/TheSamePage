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
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(viewModel.bassGuitarBacklineItems) { bassGuitarBacklineItem in
                ShowBacklineRow(title: bassGuitarBacklineItem.name, subtitle: bassGuitarBacklineItem.notes, iconName: "bass guitar")
            }
        }
    }
}

struct BassGuitarBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        BassGuitarBacklineList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
