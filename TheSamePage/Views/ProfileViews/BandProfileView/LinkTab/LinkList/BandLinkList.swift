//
//  BandLinkList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct BandLinkList: View {    
    @ObservedObject var viewModel: BandProfileViewModel
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(viewModel.bandLinks.enumerated()), id: \.element) { index, link in
                ZStack {
                    VStack {
                        HStack {
                            Link(destination: URL(string: link.url)!) {
                                BandLinkRow(viewModel: viewModel, index: index)
                            }
                            .tint(.primary)

                            Spacer()

                            // This force unwrap is safe because this list is only shown if viewModel.band != nil
                            if viewModel.band!.loggedInUserIsInvolvedWithBand {
                                BandLinkMenuButton(viewModel: viewModel, link: link)
                            }
                        }

                        Divider()
                    }
                }
            }
        }
    }
}
    
    struct BandLinkList_Previews: PreviewProvider {
        static var previews: some View {
            BandLinkList(viewModel: BandProfileViewModel(band: Band.example))
        }
    }
