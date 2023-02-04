//
//  BandLinkCard.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/30/22.
//

import SwiftUI

struct BandLinkRow: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    let index: Int
    
    var body: some View {
        if viewModel.bandLinks.indices.contains(index) {
            let link = viewModel.bandLinks[index]

            ListRowElements(
                title: link.platformName,
                iconName: link.platformName.lowercased()
            )
        }
    }
}

struct BandLinkRow_Previews: PreviewProvider {
    static var previews: some View {
        BandLinkRow(viewModel: BandProfileViewModel(band: Band.example), index: 0)
    }
}
