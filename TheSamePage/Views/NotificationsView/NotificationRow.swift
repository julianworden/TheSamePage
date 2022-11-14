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
                title: notificationTitle,
                subtitle: anyUserNotification.notification.message,
                iconName: iconName,
                displayChevron: false,
                displayDivider: false
            )
            
            if notificationType == .bandInvite || notificationType == .showInvite {
                HStack {
                    Button("Accept") {
                        viewModel.handleNotification(anyUserNotification: anyUserNotification, withAction: .accept)
                    }
                    
                    Button("Decline") {
                        viewModel.handleNotification(anyUserNotification: anyUserNotification, withAction: .decline)
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
        }
    }
    
    var notificationType: NotificationType {
        let notificationTypeAsString = anyUserNotification.notification.notificationType
        return NotificationType(rawValue: notificationTypeAsString)!
    }
    
    var notificationTitle: String {
        switch notificationType {
        case .showInvite:
            return "Show Invite"
        case .bandInvite:
            return "Band Invite"
        case .showApplication:
            return "Show Application"
        }
    }
    
    var iconName: String {
        switch notificationType {
        case .bandInvite:
            return "band"
        case .showInvite:
            return "stage"
        case .showApplication:
            return "notepad"
        }
    }
}

//struct NotificationRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationRow(viewModel: NotificationsViewModel(), anyUserNotification: AnyUserNotification)
//    }
//}
