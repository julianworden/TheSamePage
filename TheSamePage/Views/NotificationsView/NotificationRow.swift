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
                    Label("Accept", systemImage: "checkmark.circle")
                }

                AsyncButton {
                    await viewModel.handleNotification(anyUserNotification: anyUserNotification, withAction: .decline)
                } label: {
                    Label("Decline", systemImage: "x.circle")
                }

                if let showApplication = anyUserNotification.notification as? ShowApplication {
                    NavigationLink {
                        BandProfileView(band: nil, bandId: showApplication.bandId)
                    } label: {
                        Label("Band Info", systemImage: "info.circle")
                    }
                } else if let bandInvite = anyUserNotification.notification as? BandInvite {
                    NavigationLink {
                        BandProfileView(band: nil, bandId: bandInvite.bandId)
                    } label: {
                        Label("Band Info", systemImage: "info.circle")
                    }
                } else if let showInvite = anyUserNotification.notification as? ShowInvite {
                    NavigationLink {
                        ShowDetailsView(show: nil, showId: showInvite.showId)
                    } label: {
                        Label("Show Info", systemImage: "info.circle")
                    }
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
