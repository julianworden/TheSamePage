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
    
    @State private var userIsLoggedOut = AuthController.userIsLoggedOut()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !userIsLoggedOut {
                TabView(selection: $selectedTab) {
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
                    
                    NavigationView {
                        LoggedInUserProfileView(userIsLoggedOut: $userIsLoggedOut)
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(4)
                }
                .navigationBarHidden(true)
                .onAppear {
                    selectedTab = 0
                    LocationController.shared.startLocationServices()
                }
            }
        }
        .errorAlert(
            isPresented: $loggedInUserController.errorMessageShowing,
            message: loggedInUserController.errorMessageText,
            tryAgainAction: { userIsLoggedOut = true },
            tryAgainButtonText: "Log In"
        )
        .fullScreenCover(
            isPresented: $userIsLoggedOut,
            onDismiss: {
                if loggedInUserController.loggedInUser == nil {
                    Task {
                        await loggedInUserController.getLoggedInUserInfo()
                    }
                }
            },
            content: { LoginView(userIsOnboarding: $userIsLoggedOut) }
        )
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
