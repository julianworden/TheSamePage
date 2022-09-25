//
//  ContentView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct RootView: View {
    @State private var userIsOnboarding = AuthController.userIsLoggedOut()
    
    var body: some View {
        TabView {
            HomeView(userIsLoggedOut: $userIsOnboarding)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            MyShowsView()
                .tabItem {
                    Label("My Shows", systemImage: "music.mic")
                }
            
            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            
            UserProfileView(user: nil, band: nil)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
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
