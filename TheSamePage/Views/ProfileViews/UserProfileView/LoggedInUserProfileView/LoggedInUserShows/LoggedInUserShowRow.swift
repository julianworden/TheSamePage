//
//  LoggedInUserShowRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/18/23.
//

import SwiftUI

struct LoggedInUserShowRow: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    let index: Int

    var body: some View {
        if loggedInUserController.allShows.indices.contains(index) {
            let show = loggedInUserController.allShows[index]

            ListRowElements(
                title: show.name,
                subtitle: "At \(show.venue) on \(show.formattedDate)",
                iconName: "music.note.house",
                iconIsSfSymbol: true
            )
            .foregroundColor(show.alreadyHappened ? .secondary : .primary)
        }
    }
}

struct LoggedInUserShowRow_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserShowRow(index: 0)
    }
}
