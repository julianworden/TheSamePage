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
                isPresented: $loggedInUserController.errorMessageShowing,
                message: loggedInUserController.errorMessageText
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
