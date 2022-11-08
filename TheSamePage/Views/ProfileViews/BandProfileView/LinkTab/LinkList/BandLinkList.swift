//
//  BandLinkList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct BandLinkList: View {
    let columns = [GridItem(.fixed(149), spacing: 15), GridItem(.fixed(149), spacing: 15)]
    
    @ObservedObject var viewModel: BandProfileViewModel
    
    var body: some View {
        VStack {
            ForEach(Array(viewModel.bandLinks.enumerated()), id: \.element) { index, link in
                Link(destination: URL(string: link.url)!) {
                    BandLinkRow(viewModel: viewModel, index: index)
                        .padding(.horizontal)
                }
                .tint(.primary)
            }
            .background(Color(uiColor: .secondarySystemBackground))
        }
    }
}
    
    struct BandLinkList_Previews: PreviewProvider {
        static var previews: some View {
            BandLinkList(viewModel: BandProfileViewModel(band: Band.example))
        }
    }
