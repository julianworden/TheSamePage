//
//  BandLinkMenuButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/3/23.
//

import SwiftUI

struct BandLinkMenuButton: View {
    @ObservedObject var viewModel: BandProfileViewModel

    @State private var deleteLinkConfirmationAlertIsShowing = false

    let link: PlatformLink

    var body: some View {
        Menu {
            Button(role: .destructive) {
                deleteLinkConfirmationAlertIsShowing.toggle()
            } label: {
                Label("Delete Link", systemImage: "trash")
            }
        } label: {
            EllipsesMenuIcon()
        }
        .alert(
            "Are You Sure?",
            isPresented: $deleteLinkConfirmationAlertIsShowing,
            actions: {
                Button("Cancel", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    Task {
                        await viewModel.deleteBandLink(link)
                        await viewModel.getLatestBandData()
                        await viewModel.getBandLinks()
                    }
                }
            },
            message: { Text("This link will be permanently deleted.") }
        )
    }
}

struct BandLinkMenuButton_Previews: PreviewProvider {
    static var previews: some View {
        BandLinkMenuButton(viewModel: BandProfileViewModel(band: Band.example), link: PlatformLink.example)
    }
}
