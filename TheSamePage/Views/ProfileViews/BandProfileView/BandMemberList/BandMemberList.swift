//
//  BandMemberList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/1/22.
//

import SwiftUI

struct BandMemberList: View {
    @StateObject var viewModel: BandMemberListViewModel
    
    init(bandMembers: [BandMember], band: Band) {
        _viewModel = StateObject(wrappedValue: BandMemberListViewModel(bandMembers: bandMembers, band: band))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(zip(viewModel.bandMembers.indices, viewModel.bandMembers)), id: \.0) { rowIndex, bandMember in
                if !bandMember.bandMemberIsLoggedInUser {
                    NavigationLink {
                        UserProfileRootView(user: nil, bandMember: bandMember, userIsLoggedOut: .constant(false), selectedTab: .constant(4))
                    } label: {
                        BandMemberRow(bandMember: bandMember, rowIndex: rowIndex, membersCount: viewModel.bandMembers.count, bandMemberIsLoggedInUser: false)
                            .padding(.horizontal)
                    }
                    .tint(.black)
                } else {
                    BandMemberRow(bandMember: bandMember, rowIndex: rowIndex, membersCount: viewModel.bandMembers.count, bandMemberIsLoggedInUser: true)
                        .padding(.horizontal)
                }
            }
        }
    }
}

struct BandMemberList_Previews: PreviewProvider {
    static var previews: some View {
        BandMemberList(bandMembers: [BandMember.example], band: Band.example)
    }
}
