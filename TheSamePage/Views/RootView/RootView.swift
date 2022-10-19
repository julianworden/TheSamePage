//
//  ContentView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    @State private var userIsLoggedOut = AuthController.userIsLoggedOut() {
        didSet {
            if userIsLoggedOut {
                do {
                    try loggedInUserController.logOut()
                } catch {
                    print(error)
                }
            }
        }
    }
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !userIsLoggedOut {
                TabView(selection: $selectedTab) {
                    HomeView()
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
                        LoggedInUserProfileView(
                            userIsLoggedOut: $userIsLoggedOut
                        )
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
        .fullScreenCover(isPresented: $userIsLoggedOut) {
            LoginView(userIsOnboarding: $userIsLoggedOut)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
