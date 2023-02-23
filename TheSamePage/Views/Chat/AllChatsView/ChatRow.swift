//
//  ChatRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/22/23.
//

import SwiftUI

struct ChatRow: View {
    @EnvironmentObject var loggedInUser: LoggedInUserController

    let index: Int

    var body: some View {
        if loggedInUser.allUserChats.indices.contains(index) {
            let chat = loggedInUser.allUserChats[index]

            ListRowElements(
                title: chat.name ?? "",
                subtitle: chat.mostRecentMessageText ?? "",
                secondaryText: chat.mostRecentMessageTimestamp?.unixDateAsDate.timeAndDate ?? "",
                iconName: chat.showId == nil ? "person" : "music.note.house",
                iconIsSfSymbol: true,
                displayChevron: true,
                displayUnreadIndicator: !chat.loggedInUserIsUpToDate
            )
        }
    }
}

struct ChatRow_Previews: PreviewProvider {
    static var previews: some View {
        ChatRow(index: 0)
    }
}
