//
//  BandMemberListRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct BandMemberListRow: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    let index: Int
    
    var body: some View {
        if viewModel.bandMembers.indices.contains(index) {
            let bandMember = viewModel.bandMembers[index]

            HStack {
                ListRowElements(
                    title: bandMember.bandMemberIsLoggedInUser ? "You" : bandMember.fullName,
                    subtitle: bandMember.role,
                    iconName: bandMember.listRowIconName,
                    iconIsSfSymbol: false
                )
            }
        }
    }
}

struct BandMemberListRow_Previews: PreviewProvider {
    static var previews: some View {
        BandMemberListRow(viewModel: BandProfileViewModel(band: Band.example, showParticipant: nil), index: 0)
    }
}
