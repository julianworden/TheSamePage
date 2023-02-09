//
//  LinkTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct LinkTab: View {
    @ObservedObject var viewModel: BandProfileViewModel

    var body: some View {
        if let band = viewModel.band {
            VStack {
                if !viewModel.bandLinks.isEmpty {
                    BandLinkList(viewModel: viewModel)

                    Button {
                        viewModel.addEditLinkSheetIsShowing.toggle()
                    } label: {
                        Label("Add Link", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                } else if viewModel.bandLinks.isEmpty {
                    NoDataFoundMessageWithButtonView(
                        isPresentingSheet: $viewModel.addEditLinkSheetIsShowing,
                        shouldDisplayButton: band.loggedInUserIsInvolvedWithBand,
                        buttonText: "Add Link",
                        buttonImageName: "plus",
                        message: "This band doesn't have any links"
                    )
                }
            }
            .sheet(
                isPresented: $viewModel.addEditLinkSheetIsShowing,
                onDismiss: {
                    Task {
                        await viewModel.getBandLinks()
                    }
                },
                content: {
                    AddEditLinkView(link: nil, band: viewModel.band!)
                }
            )
        }
    }
}

struct LinkTab_Previews: PreviewProvider {
    static var previews: some View {
        LinkTab(viewModel: BandProfileViewModel(band: Band.example))
    }
}
