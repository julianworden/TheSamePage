//
//  ContentView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct RootView: View {
    @State private var userIsOnboarding = AuthController.userIsLoggedOut()
    @State private var selectedTab = 0
    
    var body: some View {
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
            
            MyShowsView()
                .tabItem {
                    Label("My Shows", systemImage: "music.mic")
                }
                .tag(1)
            
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
                .tag(2)
            
            UserProfileView(user: nil, band: nil, bandMember: nil, userIsLoggedOut: $userIsOnboarding, selectedTab: $selectedTab)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(3)
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $userIsOnboarding) {
            LoginView(userIsOnboarding: $userIsOnboarding)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(ShowsController())
    }
}
