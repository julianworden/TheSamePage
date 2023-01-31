//
//  BandMemberList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/1/22.
//

import SwiftUI

struct BandMemberList: View {
    @ObservedObject var viewModel: BandProfileViewModel

    @State private var selectedBandMember: BandMember?
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(viewModel.bandMembers.enumerated()), id: \.element) { index, bandMember in
                NavigationLink {
                    OtherUserProfileView(user: nil, bandMember: bandMember)
                } label: {
                    BandMemberListRow(
                        viewModel: viewModel,
                        index: index
                    )
                }
                .tint(.primary)
                .allowsHitTesting(bandMember.bandMemberIsLoggedInUser ? false : true)

                Divider()
            }
        }
    }
}

struct BandMemberList_Previews: PreviewProvider {
    static var previews: some View {
        BandMemberList(viewModel: BandProfileViewModel(band: Band.example, showParticipant: nil))
    }
}
