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
                    iconName: bandMember.listRowIconName
                )

                // Force unwrap is safe because the only way this list is visible is if viewModel.band != nil
                if !bandMember.bandMemberIsLoggedInUser && viewModel.band!.loggedInUserIsBandAdmin {
                    Button(role: .destructive) {
                        viewModel.removeBandMemberFromBandConfirmationAlertIsShowing.toggle()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .alert(
                        "Are You Sure?",
                        isPresented: $viewModel.removeBandMemberFromBandConfirmationAlertIsShowing,
                        actions: {
                            Button("Cancel", role: .cancel) { }
                            Button("Yes", role: .destructive) {
                                Task {
                                    await viewModel.removeBandMemberFromBand(bandMember: bandMember)
                                    await viewModel.getBandMembers()
                                    await viewModel.getLatestBandData()
                                }
                            }
                        },
                        message: { Text("If you remove this user from \(viewModel.band!.name), they will no longer be able to access chats and private data for shows in which \(viewModel.band!.name) is a participant.") }
                    )
                }
            }
        }
    }
}

struct BandMemberListRow_Previews: PreviewProvider {
    static var previews: some View {
        BandMemberListRow(viewModel: BandProfileViewModel(band: Band.example, showParticipant: nil), index: 0)
    }
}
