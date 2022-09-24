//
//  NotificationsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()
    
    var body: some View {
        List(viewModel.fetchedNotifications) { invite in
            NotificationRow(notification: invite)
        }
        .navigationTitle("Notifications")
        .task {
            do {
                try await viewModel.getNotifications()
            } catch {
                print(error)
            }
        }
    }
}


struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NotificationsView(
                viewModel: { () -> NotificationsViewModel in
                    let viewModel = NotificationsViewModel()
                    
                    viewModel.fetchedNotifications = [BandInvite.example]
                    return viewModel
                }()
            )
        }
    }
}
