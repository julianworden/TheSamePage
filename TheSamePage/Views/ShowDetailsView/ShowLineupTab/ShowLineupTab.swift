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
                        Label("Invite Band", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                    .fullScreenCover(isPresented: $viewModel.bandSearchViewIsShowing) {
                        NavigationView {
                            BandSearchView(isPresentedModally: true)
                        }
                    }
                }
            } else if show.loggedInUserIsShowHost {
                VStack(spacing: 7) {
                    Text("No bands are playing this show yet.")
                        .multilineTextAlignment(.center)

                    NavigationLink {
                        BandSearchView()
                    } label: {
                        Label("Invite Band", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if show.loggedInUserIsNotInvolvedInShow || show.loggedInUserIsShowParticipant {
                Text("No bands are playing this show yet. Only the show's host can invite bands to play.")
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal)
    }
}

struct ShowLineupTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
