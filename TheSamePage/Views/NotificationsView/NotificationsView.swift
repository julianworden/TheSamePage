//
//  NotificationsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @StateObject var viewModel = NotificationsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                NotificationsList(viewModel: viewModel)
            }
            .navigationTitle("Notifications")
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText,
                okButtonAction: {
                    if loggedInUserController.allUserNotifications.isEmpty {
                        viewModel.viewState = .dataNotFound
                    } else {
                        viewModel.viewState = .dataLoaded
                    }
                }
            )
        }
    }
}

// Switch to Selectable preview to make this work
struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(viewModel: NotificationsViewModel())
    }
}
