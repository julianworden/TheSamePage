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
                    switch viewModel.viewState {
                    case .dataLoading:
                        ProgressView()
                        
                    case .dataLoaded:
                        NotificationsList(viewModel: viewModel)
                        
                    case .dataNotFound:
                        NoDataFoundMessage(message: "You do not have any pending notifications.")
                        
                    case .error:
                        EmptyView()
                        
                    default:
                        ErrorMessage(message: "Unknown viewState")
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Notifications")
            .errorAlert(
                isPresented: $viewModel.errorAlertIsShowing,
                message: viewModel.errorAlertText,
                tryAgainAction: {
                    viewModel.getNotifications()
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
