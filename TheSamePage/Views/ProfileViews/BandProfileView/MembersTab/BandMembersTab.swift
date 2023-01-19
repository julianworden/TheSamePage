//
//  BandMembersTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct BandMembersTab: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    var body: some View {
        Group {
            if let band = viewModel.band {
                if !viewModel.bandMembers.isEmpty {
                    BandMemberList(viewModel: viewModel)

                    Button {
                        viewModel.addBandMemberSheetIsShowing.toggle()
                    } label: {
                        Label("Invite Member", systemImage: "envelope")
                    }
                    .buttonStyle(.bordered)
                } else {
                    NoDataFoundMessageWithButtonView(
                        isPresentingSheet: $viewModel.addBandMemberSheetIsShowing,
                        shouldDisplayButton: band.loggedInUserIsInvolvedWithBand,
                        buttonText: "Invite Member",
                        buttonImageName: "envelope",
                        message: "This band does not have any members"
                    )
                }
            }
        }
        .fullScreenCover(
            isPresented: $viewModel.addBandMemberSheetIsShowing,
            content: {
                NavigationView {
                    MemberSearchView()
                }
            }
        )
    }
}

struct BandMembersTab_Previews: PreviewProvider {
    static var previews: some View {
        BandMembersTab(viewModel: BandProfileViewModel(band: Band.example))
    }
}
