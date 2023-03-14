//
//  OtherUserShowRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 3/3/23.
//

import SwiftUI

struct OtherUserShowRow: View {
    @ObservedObject var viewModel: OtherUserProfileViewModel

    let index: Int

    var body: some View {
        if viewModel.shows.indices.contains(index) {
            let show = viewModel.shows[index]

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

struct OtherUserShowRow_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserShowRow(viewModel: OtherUserProfileViewModel(user: nil), index: 0)
    }
}
