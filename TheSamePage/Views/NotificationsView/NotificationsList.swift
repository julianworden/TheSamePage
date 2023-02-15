//
//  NotificationsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/6/22.
//

import SwiftUI

struct NotificationsList: View {
    @ObservedObject var viewModel: NotificationsViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: UiConstants.listRowSpacing) {
                ForEach(viewModel.fetchedNotifications) { anyUserNotification in
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
