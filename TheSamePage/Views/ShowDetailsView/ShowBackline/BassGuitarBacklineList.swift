//
//  BassGuitarBacklineList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/22/22.
//

import SwiftUI

struct BassGuitarBacklineList: View {
    @ObservedObject var viewModel: ShowBacklineTabViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.bassGuitarBacklineItems) { bassGuitarBacklineItem in
                SmallListRow(title: bassGuitarBacklineItem.name, subtitle: bassGuitarBacklineItem.notes, iconName: "bass guitar", displayChevron: false)
            }
        }
        .padding(.horizontal)
    }
}

struct BassGuitarBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        BassGuitarBacklineList(viewModel: ShowBacklineTabViewModel(show: Show.example))
    }
}
