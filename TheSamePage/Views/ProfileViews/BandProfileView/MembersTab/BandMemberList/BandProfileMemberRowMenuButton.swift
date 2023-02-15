//
//  BandProfileMemberRowMenuButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/2/23.
//

import SwiftUI

struct BandProfileMemberRowMenuButton: View {
    @ObservedObject var viewModel: BandProfileViewModel

    @State private var removeBandMemberFromBandConfirmationAlertIsShowing = false

    let bandMember: BandMember

    var body: some View {
        Menu {
            Button(role: .destructive) {
                removeBandMemberFromBandConfirmationAlertIsShowing.toggle()
            } label: {
                Label("Remove User from Band", systemImage: "trash")
            }
        } label: {
            EllipsesMenuIcon()
        }
        .buttonStyle(.bordered)
        .alert(
            "Are You Sure?",
            isPresented: $removeBandMemberFromBandConfirmationAlertIsShowing,
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

struct BandProfileMemberRowMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileMemberRowMenuButton(viewModel: BandProfileViewModel(band: Band.example), bandMember: BandMember.example)
    }
}
