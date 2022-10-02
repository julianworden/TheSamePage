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
        NavigationView {
            Group {
                if !viewModel.fetchedNotifications.isEmpty {
                    ScrollView {
                        ForEach(viewModel.fetchedNotifications) { invite in
                            NotificationRow(notification: invite)
                        }
                        .onDisappear {
                            viewModel.removeListeners()
                        }
                        .animation(.easeInOut, value: viewModel.fetchedNotifications)
                    }
                    
                } else {
                    VStack {
                        Text("Band invites, new messages, and more will appear here. You don't have any notifications at this time.")
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Notifications")
            .task {
                do {
                    try viewModel.getNotifications()
                } catch {
                    print(error)
                }
            }
        }
    }
}

// Switch to Selectable preview to make this work
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(
            viewModel: { () -> NotificationsViewModel in
                let viewModel = NotificationsViewModel()
                
                viewModel.fetchedNotifications = [BandInvite.example]
                return viewModel
            }()
        )
    }
}
