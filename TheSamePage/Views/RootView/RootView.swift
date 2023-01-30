//
//  ContentView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Collections
import SwiftUI

struct RootView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    @EnvironmentObject var networkController: NetworkController
    
    @StateObject var viewModel = RootViewModel()

    var body: some View {
        ZStack {
            BackgroundColor()
            
            if !loggedInUserController.userIsLoggedOut {
                TabView(selection: $viewModel.selectedTab) {
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

                    LoggedInUserProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(4)
                }
                .task {
                    await loggedInUserController.validateIfUserHasUsername()
                }
                .alert(
                    "Error",
                    isPresented: $loggedInUserController.currentUserHasNoUsernameAlertIsShowing,
                    actions: {
                        Button("Create a Username") { loggedInUserController.createUsernameSheetIsShowing = true }
                    },
                    message: { Text("You need a username to use The Same Page, but you have not set one up yet.") }
                )
                .fullScreenCover(isPresented: $loggedInUserController.createUsernameSheetIsShowing) {
                    NavigationView {
                        CreateUsernameView(signUpFlowIsActive: .constant(false))
                    }
                }
            }
        }
        .fullScreenCover(
            isPresented: $loggedInUserController.currentUserIsInvalid,
            onDismiss: {
                viewModel.selectedTab = 0
                Task {
                    await loggedInUserController.callOnAppLaunchMethods()
                    LocationController.shared.startLocationServices()
                }
            },
            content: {
                LoginView()
            }
        )
        .task {
            await loggedInUserController.validateUserLogInStatusAndEmailVerification()
            if !loggedInUserController.currentUserIsInvalid && !loggedInUserController.currentUserHasNoUsernameAlertIsShowing {
                await loggedInUserController.callOnAppLaunchMethods()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
