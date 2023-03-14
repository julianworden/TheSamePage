//
//  ShowLineupList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/7/22.
//

import SwiftUI

struct ShowLineupList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        if let show = viewModel.show {
            VStack(spacing: UiConstants.listRowSpacing) {
                ForEach(Array(viewModel.showParticipants.enumerated()), id: \.element) { index, showParticipant in
                    ZStack {
                        VStack {
                            HStack {
                                NavigationLink {
                                    BandProfileView(band: nil, showParticipant: showParticipant)
                                } label: {
                                    ShowLineupRow(viewModel: viewModel, index: index)
                                }
                                .tint(.primary)

                                Spacer()

                                if show.loggedInUserIsShowHost || showParticipant.bandAdminIsLoggedInUser {
                                    ShowLineupRowMenuButton(viewModel: viewModel, showParticipant: showParticipant)
                                }
                            }

                            Divider()
                        }
                    }
                }
            }
            .padding(.top, 5)
            .sheet(
                item: $viewModel.showParticipantToEdit,
                onDismiss: {
                    Task {
                        await viewModel.getShowParticipants()
                        await viewModel.getLatestShowData()
                    }
                },
                content: { showParticipant in
                    AddEditSetTimeView(show: show, showParticipant: showParticipant)
                }
            )
        }
    }
}

struct ShowLineupList_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
