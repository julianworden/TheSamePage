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

    @ObservedObject var appOpenedViaNotificationController: AppOpenedViaNotificationController

    var body: some View {
        ZStack {
            BackgroundColor()

            if !loggedInUserController.userIsLoggedOut,
               loggedInUserController.loggedInUser != nil {
                TabView(selection: $appOpenedViaNotificationController.selectedRootViewTab) {
                    FindShowsView()
                        .tabItem {
                            Label("Find Shows", systemImage: "square.stack")
                        }
                        .tag(0)

                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .tag(1)

                    MyShowsRootView()
                        .tabItem {
                            Label("My Shows", systemImage: "music.note.house")
                        }
                        .tag(2)

                    NotificationsView()
                        .tabItem {
                            Label("Notifications", systemImage: "bell")
                        }
                        .tag(3)
                        .badge(loggedInUserController.allUserNotifications.count)

                    LoggedInUserProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(4)
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
                    NavigationStack {
                        CreateUsernameView(navigationViewModel: OnboardingNavigationViewModel())
                    }
                }
            } else if loggedInUserController.loggedInUser == nil {
                 ProgressView()
            }
        }
        .fullScreenCover(
            isPresented: $loggedInUserController.currentUserIsInvalid,
            onDismiss: {
                appOpenedViaNotificationController.selectedRootViewTab = 0
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
            await loggedInUserController.validateIfUserHasUsername()
            if !loggedInUserController.currentUserIsInvalid && !loggedInUserController.currentUserHasNoUsernameAlertIsShowing {
                await loggedInUserController.callOnAppLaunchMethods()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(appOpenedViaNotificationController: AppOpenedViaNotificationController())
    }
}
