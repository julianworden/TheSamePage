//
//  ContentView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    @EnvironmentObject var networkController: NetworkController
    
    @StateObject var viewModel = RootViewModel()
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
            if !viewModel.userIsLoggedOut {
                TabView(selection: $viewModel.selectedTab) {
                    HomeView()
                        .environmentObject(MyShowsViewModel())
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag(0)
                    
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(1)
                    
                    MyShowsRootView()
                        .tabItem {
                            Label("My Shows", systemImage: "music.mic")
                        }
                        .tag(2)
                    
                    NotificationsView()
                        .tabItem {
                            Label("Notifications", systemImage: "bell")
                        }
                        .tag(3)
                    
                        LoggedInUserProfileView(userIsLoggedOut: $viewModel.userIsLoggedOut)
                            .tabItem {
                                Label("Profile", systemImage: "person")
                            }
                            .tag(4)
                    
                }
                .onAppear {
                    LocationController.shared.startLocationServices()
                }
            }
        }
        .errorAlert(
            isPresented: $loggedInUserController.errorMessageShowing,
            message: loggedInUserController.errorMessageText,
            tryAgainAction: { viewModel.userIsLoggedOut = true },
            tryAgainButtonText: "Log In"
        )
        .fullScreenCover(
            isPresented: $viewModel.userIsLoggedOut,
            onDismiss: {
                viewModel.selectedTab = 0
                
                if loggedInUserController.loggedInUser == nil {
                    Task {
                        await loggedInUserController.getLoggedInUserInfo()
                    }
                }
            },
            content: { LoginView(userIsOnboarding: $viewModel.userIsLoggedOut) }
        )
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
