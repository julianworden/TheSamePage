//
//  ShowBacklineRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/2/22.
//

import SwiftUI

struct ShowBacklineRow: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    var backlineItem: BacklineItem?
    var drumKitBacklineItem: DrumKitBacklineItem?
    let title: String
    let subtitle: String?
    let iconName: String
    
    var body: some View {
        HStack {
            ListRowElements(
                title: title,
                subtitle: subtitle,
                iconName: iconName
            )

            Spacer()

            if let backlineItem {
                if backlineItem.loggedInUserIsBackliner || viewModel.show.loggedInUserIsShowHost {
                    Button(role: .destructive) {
                        viewModel.deleteBacklineItemConfirmationAlertIsShowing.toggle()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .alert(
                        "Are You Sure?",
                        isPresented: $viewModel.deleteBacklineItemConfirmationAlertIsShowing,
                        actions: {
                            Button("Cancel", role: .cancel) { }
                            Button("Yes", role: .destructive) {
                                Task {
                                    await viewModel.deleteBacklineItem(backlineItem)
                                    await viewModel.getBacklineItems()
                                }
                            }
                        },
                        message: { Text("This backline item will be permanently deleted from this show.") }
                    )
                }
            } else if let drumKitBacklineItem {
                if drumKitBacklineItem.loggedInUserIsBackliner || viewModel.show.loggedInUserIsShowHost {
                    Button(role: .destructive) {
                        viewModel.deleteDrumKitBacklineItemConfirmationAlertIsShowing.toggle()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .alert(
                        "Are You Sure?",
                        isPresented: $viewModel.deleteDrumKitBacklineItemConfirmationAlertIsShowing,
                        actions: {
                            Button("Cancel", role: .cancel) { }
                            Button("Yes", role: .destructive) {
                                Task {
                                    await viewModel.deleteDrumKitBacklineItem(drumKitBacklineItem)
                                    await viewModel.getBacklineItems()
                                }
                            }
                        },
                        message: { Text("This backline item will be permanently deleted from this show.") }
                    )
                }
            }
        }
    }
}

struct ShowBacklineRow_Previews: PreviewProvider {
    static var previews: some View {
        ShowBacklineRow(
            viewModel: ShowDetailsViewModel(show: Show.example),
            title: "Drums",
            subtitle: "Kick, snare, toms",
            iconName: "drums"
        )
    }
}
