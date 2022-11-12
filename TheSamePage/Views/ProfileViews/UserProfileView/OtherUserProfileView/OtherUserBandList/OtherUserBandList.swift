//
//  UserBandList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct OtherUserBandList: View {
    @ObservedObject var viewModel: OtherUserProfileViewModel
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(viewModel.bands.enumerated()), id: \.element) { index, band in
                NavigationLink {
                    BandProfileView(band: band)
                } label: {
                    OtherUserBandRow(viewModel: viewModel, index: index)
                }
                .tint(.primary)
                .padding(.horizontal)
            }
            .animation(.easeInOut, value: viewModel.bands)
        }
    }
}

struct OtherUserBandList_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserBandList(viewModel: OtherUserProfileViewModel(user: User.example, bandMember: nil))
    }
}
