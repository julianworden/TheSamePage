//
//  ShowLineupTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowLineupTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        let show = viewModel.show
        
        VStack {
            if !viewModel.showParticipants.isEmpty {
                HStack {
                    Text(viewModel.showSlotsRemainingMessage)
                        .font(.title3.bold())

                    Spacer()
                }

                ShowLineupList(viewModel: viewModel)

                if show.loggedInUserIsShowHost && !show.lineupIsFull {
                    Button {
                        viewModel.bandSearchViewIsShowing.toggle()
                    } label: {
                        Label("Invite Band", systemImage: "envelope")
                    }
                    .buttonStyle(.bordered)

                }
            } else {
                NoDataFoundMessageWithButtonView(
                    isPresentingSheet: $viewModel.bandSearchViewIsShowing,
                    shouldDisplayButton: show.loggedInUserIsShowHost,
                    buttonText: "Invite Band",
                    buttonImageName: "envelope",
                    message: viewModel.noShowParticipantsText
                )
            }
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $viewModel.bandSearchViewIsShowing) {
            NavigationView {
                BandSearchView(isPresentedModally: true)
            }
        }
    }
}

struct ShowLineupTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
