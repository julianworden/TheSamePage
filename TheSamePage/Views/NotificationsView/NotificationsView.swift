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
        NavigationStack {
            ZStack {
                BackgroundColor()
                
                VStack {
                    switch viewModel.viewState {
                    case .dataLoading:
                        ProgressView()
                        
                    case .dataLoaded, .performingWork, .workCompleted:
                        NotificationsList(viewModel: viewModel)
                        
                    case .dataNotFound:
                        NoDataFoundMessage(message: "You do not have any pending notifications.")
                        
                    case .error:
                        EmptyView()
                        
                    default:
                        ErrorMessage(message: "Unknown viewState")
                    }
                    
//                    Spacer()
                }
            }
            .navigationTitle("Notifications")
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText,
                okButtonAction: {
                    if viewModel.fetchedNotifications.isEmpty {
                        viewModel.viewState = .dataNotFound
                    } else {
                        viewModel.viewState = .dataLoaded
                    }
                }
            )
            .task {
                viewModel.getNotifications()
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
