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
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    if !viewModel.fetchedNotifications.isEmpty {
                        NotificationsList(viewModel: viewModel)
                    } else {
                        NoDataFoundMessage(message: "You do not have any pending band invites.")
                    }
                    
                    Spacer()
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
            .onDisappear {
                viewModel.removeListeners()
            }
        }
    }
}

// Switch to Selectable preview to make this work
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(viewModel: NotificationsViewModel())
    }
}
