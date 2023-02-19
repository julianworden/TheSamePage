//
//  LoggedInUserShowsTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/18/23.
//

import SwiftUI

struct LoggedInUserShowsTab: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    var body: some View {
        if !loggedInUserController.allShows.isEmpty {
            LoggedInUserShowList()
                .padding(.top, 5)
        } else {
            NoDataFoundMessage(message: "You haven't played any shows on The Same Page.")
        }

    }
}

struct LoggedInUserShowsTab_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserShowsTab()
    }
}
