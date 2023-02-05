//
//  ShowBacklineRowMenuButton.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/4/23.
//

import SwiftUI

struct ShowBacklineRowMenuButton: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    @State private var deleteBacklineItemConfirmationAlertIsShowing = false

    let anyBackline: AnyBackline

    var body: some View {
        Menu {
            Button(role: .destructive) {
                deleteBacklineItemConfirmationAlertIsShowing.toggle()
            } label: {
                Label("Delete Backline Item", systemImage: "trash")
            }
        } label: {
            EllipsesMenuIcon()
        }
        .alert(
            "Are You Sure?",
            isPresented: $deleteBacklineItemConfirmationAlertIsShowing,
            actions: {
                Button("Cancel", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    Task {
                        await viewModel.deleteBackline(anyBackline.backline)
                        await viewModel.getBacklineItems()
                    }
                }
            },
            message: { Text("This backline item will be permanently deleted from this show.") }
        )
    }
}

//struct ShowBacklineRowMenuButton_Previews: PreviewProvider {
//    static var previews: some View {
//        ShowBacklineRowMenuButton()
//    }
//}
