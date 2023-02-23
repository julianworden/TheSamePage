//
//  NotificationsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/6/22.
//

import SwiftUI

struct NotificationsList: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @ObservedObject var viewModel: NotificationsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: UiConstants.listRowSpacing) {
                ForEach(loggedInUserController.allUserNotifications) { anyUserNotification in
                    NotificationRow(viewModel: viewModel, anyUserNotification: anyUserNotification)

                    Divider()
                }
            }
            .padding(.horizontal)
        }
    }
}

struct BandInvitesList_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsList(viewModel: NotificationsViewModel())
    }
}
