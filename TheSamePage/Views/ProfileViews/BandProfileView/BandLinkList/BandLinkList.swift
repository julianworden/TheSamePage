//
//  BandLinkList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct BandLinkList: View {
    let columns = [GridItem(.fixed(149), spacing: 15), GridItem(.fixed(149), spacing: 15)]
    
    @StateObject var viewModel: BandLinkListViewModel
    
    init(bandLinks: [Link]) {
        _viewModel = StateObject(wrappedValue: BandLinkListViewModel(bandLinks: bandLinks))
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 15) {
            ForEach(viewModel.bandLinks) { link in
                BandLinkCard(link: link)
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
}

struct BandLinkList_Previews: PreviewProvider {
    static var previews: some View {
        BandLinkList(bandLinks: [Link.example])
    }
}
