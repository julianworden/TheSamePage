//
//  LoggedInUserShowList.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/18/23.
//

import SwiftUI

struct LoggedInUserShowList: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(loggedInUserController.allShows.enumerated()), id: \.element) { index, show in
                NavigationLink {
                    ShowDetailsView(show: show)
                } label: {
                    LoggedInUserShowRow(index: index)
                }

                Divider()
            }
        }
    }
}

struct LoggedInUserShowList_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserShowList()
    }
}
