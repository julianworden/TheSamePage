//
//  NotificationRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import SwiftUI

struct NotificationRow: View {
    @ObservedObject var viewModel: NotificationsViewModel
    
    let anyUserNotification: AnyUserNotification
    
    // TODO: Add notification timestamp
    var body: some View {
        VStack {
            ListRowElements(
                title: anyUserNotification.notificationTitle,
                subtitle: anyUserNotification.notification.message,
                iconName: anyUserNotification.iconName
            )
            
            HStack {
                AsyncButton {
                    await viewModel.handleNotification(anyUserNotification: anyUserNotification, withAction: .accept)
                } label: {
                    Text("Accept")
                }

                AsyncButton {
                    await viewModel.handleNotification(anyUserNotification: anyUserNotification, withAction: .decline)
                } label: {
                    Text("Decline")
                }
            }
            .buttonStyle(.bordered)

            Divider()
        }
    }
}

//struct NotificationRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationRow(viewModel: NotificationsViewModel(), anyUserNotification: AnyUserNotification)
//    }
//}
