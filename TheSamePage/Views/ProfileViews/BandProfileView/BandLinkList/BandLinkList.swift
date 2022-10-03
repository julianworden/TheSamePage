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
    
    init(bandLinks: [PlatformLink]) {
        _viewModel = StateObject(wrappedValue: BandLinkListViewModel(bandLinks: bandLinks))
    }
    
    var body: some View {
        VStack {
            ForEach(viewModel.bandLinks) { link in
                Link(destination: URL(string: link.url)!) {
                    BandLinkCard(link: link)
                }
            }
            .background(Color(uiColor: .secondarySystemBackground))
        }
    }
}
    
    struct BandLinkList_Previews: PreviewProvider {
        static var previews: some View {
            BandLinkList(bandLinks: [PlatformLink.example])
        }
    }
