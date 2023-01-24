//
//  ShowLineupRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/26/22.
//

import SwiftUI

struct ShowLineupRow: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    let index: Int
    
    var body: some View {
        let showParticipant = viewModel.showParticipants[index]

        HStack {
            ListRowElements(
                title: showParticipant.name,
                iconName: "band"
            )

            Spacer()

            if viewModel.show.loggedInUserIsShowHost {
                Button(role: .destructive) {
                    viewModel.removeShowParticipantConfirmationAlertIsShowing.toggle()
                } label: {
                    Image(systemName: "trash")
                }
                .alert(
                    "Are You Sure?",
                    isPresented: $viewModel.removeShowParticipantConfirmationAlertIsShowing,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                        Button("Yes", role: .destructive) {
                            Task {
                                await viewModel.removeShowParticipantFromShow(showParticipant: showParticipant)
                                await viewModel.getShowParticipants()
                            }
                        }
                    },
                    message: { Text("All of this band's members will lose access to this show's private data and chat.") }
                )
            }
        }
    }
}

struct ShowLineupRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupRow(viewModel: ShowDetailsViewModel(show: Show.example), index: 0)
    }
}
