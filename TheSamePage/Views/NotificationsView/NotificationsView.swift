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
                    Picker("Select Notification Type", selection: $viewModel.selectedNotificationType) {
                        ForEach(NotificationType.allCases) { notificationType in
                            Text(notificationType.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if viewModel.selectedNotificationType == .bandInvite {
                        BandInvitesList(viewModel: viewModel)
                    }
                    
                    if viewModel.selectedNotificationType == .showInvite {
                        ShowInvitesList(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Notifications")
        }
    }
}

// Switch to Selectable preview to make this work
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(
            viewModel: { () -> NotificationsViewModel in
                let viewModel = NotificationsViewModel()
                
                viewModel.fetchedBandInvites = [BandInvite.example]
                return viewModel
            }()
        )
    }
}
