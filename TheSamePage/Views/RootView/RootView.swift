//
//  ContentView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var userController: UserController
    
    @State private var userIsLoggedOut = AuthController.userIsLoggedOut()
    
    var body: some View {
        TabView {
            HomeView(userIsLoggedOut: $userIsLoggedOut)
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
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .navigationBarHidden(true)
        .fullScreenCover(
            isPresented: $userIsLoggedOut,
            onDismiss: {
                Task {
                    do {
                        try await userController.initializeUser()
                    } catch {
                        print(error)
                    }
                }
            }, content: {
                LoginView(userIsLoggedOut: $userIsLoggedOut)
            }
        )
    }
}
    
    struct RootView_Previews: PreviewProvider {
        static var previews: some View {
            RootView()
                .environmentObject(ShowsController())
                .environmentObject(UserController())
        }
    }
