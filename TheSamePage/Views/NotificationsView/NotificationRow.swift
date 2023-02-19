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
        HStack {
            ListRowElements(
                title: anyUserNotification.notificationTitle,
                subtitle: anyUserNotification.notification.message,
                secondaryText: anyUserNotification.notification.sentTimestamp.unixDateAsDate.timeOmittedNumericDate,
                iconName: anyUserNotification.iconName,
                iconIsSfSymbol: false
            )

            HStack {
                Button {
                    Task {
                        await viewModel.handleNotification(anyUserNotification: anyUserNotification, withAction: .accept)
                    }
                } label: {
                    Image(systemName: "checkmark.circle")
                }
                .disabled(viewModel.buttonsAreDisabled)

                Button {
                    Task {
                        await viewModel.handleNotification(anyUserNotification: anyUserNotification, withAction: .decline)
                    }
                } label: {
                    Image(systemName: "x.circle")
                }
                .disabled(viewModel.buttonsAreDisabled)

                if let showApplication = anyUserNotification.notification as? ShowApplication {
                    NavigationLink {
                        BandProfileView(band: nil, bandId: showApplication.bandId)
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .disabled(viewModel.buttonsAreDisabled)

                } else if let bandInvite = anyUserNotification.notification as? BandInvite {
                    NavigationLink {
                        BandProfileView(band: nil, bandId: bandInvite.bandId)
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .disabled(viewModel.buttonsAreDisabled)

                } else if let showInvite = anyUserNotification.notification as? ShowInvite {
                    NavigationLink {
                        ShowDetailsView(show: nil, showId: showInvite.showId)
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                    
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

//struct NotificationRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        NotificationRow(viewModel: NotificationsViewModel(), anyUserNotification: AnyUserNotification)
//    }
//}
