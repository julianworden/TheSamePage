//
//  ElectricGuitarBacklineList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/22/22.
//

import SwiftUI

struct ElectricGuitarBacklineList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.electricGuitarBacklineItems) { electricGuitarBacklineItem in
                ShowBacklineRow(title: electricGuitarBacklineItem.name, subtitle: electricGuitarBacklineItem.notes, iconName: "guitar")
            }
        }
        .padding(.horizontal)
    }
}

struct ElectricGuitarBacklineList_Previews: PreviewProvider {
    static var previews: some View {
        ElectricGuitarBacklineList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
