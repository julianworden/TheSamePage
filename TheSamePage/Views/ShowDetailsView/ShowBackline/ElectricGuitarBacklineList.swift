//
//  ElectricGuitarBacklineList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/22/22.
//

import SwiftUI

struct ElectricGuitarBacklineList: View {
    @ObservedObject var viewModel: ShowBacklineTabViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.electricGuitarBacklineItems) { electricGuitarBacklineItem in
                SmallListRow(title: electricGuitarBacklineItem.name, subtitle: electricGuitarBacklineItem.notes, iconName: "guitar", displayChevron: false)
            }
        }
        .padding(.horizontal)
    }
}

struct ElectricGuitarBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        ElectricGuitarBacklineList(viewModel: ShowBacklineTabViewModel(show: Show.example))
    }
}
