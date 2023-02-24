//
//  TheSamePageApp.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDynamicLinks
import FirebaseFirestore
import FirebaseFunctions
import FirebaseMessaging
import FirebaseStorage
import SwiftUI

@main
struct TheSamePageApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @StateObject var loggedInUserController = LoggedInUserController()
    @StateObject var networkController = NetworkController()
    @StateObject var appOpenedViaNotificationController = AppOpenedViaNotificationController()

    var body: some Scene {
        WindowGroup {
            if !appOpenedViaNotificationController.appNotificationTapped {
                RootView(appOpenedViaNotificationController: appOpenedViaNotificationController)
                    .fullScreenCover(isPresented: $appOpenedViaNotificationController.presentViewFromNotification) {
                        NavigationStack {
                            appOpenedViaNotificationController.sheetView()
                                .environmentObject(loggedInUserController)
                        }
                    }
                    .environmentObject(loggedInUserController)
                    .environmentObject(networkController)
                    .environmentObject(appOpenedViaNotificationController)
                    .onOpenURL { url in
                        print("App opened via Dynamic Link.")
                        print("Incoming URL at app startup is \(url)")
                        
                        DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
                            guard error == nil else {
                                print("Error: \(error!.localizedDescription)")
                                return
                            }

                            if let dynamicLink {
                                self.handleIncomingDynamicLink(dynamicLink)
                            }
                        }
                    }
                    .onAppear {
                        if appOpenedViaNotificationController.presentViewFromNotification == true {
                            appOpenedViaNotificationController.presentViewFromNotification = false
                            appOpenedViaNotificationController.presentViewFromNotification = true
                        }
                    }
            } else {
                RootView(appOpenedViaNotificationController: appOpenedViaNotificationController)
                    .fullScreenCover(isPresented: $appOpenedViaNotificationController.presentViewFromNotification) {
                        NavigationStack {
                            appOpenedViaNotificationController.sheetView()
                                .environmentObject(loggedInUserController)
                        }
                    }
                    .environmentObject(loggedInUserController)
                    .environmentObject(networkController)
                    .environmentObject(appOpenedViaNotificationController)
                    .onOpenURL { url in
                        print("App opened via Dynamic Link.")
                        print("Incoming URL at app startup is \(url)")
                        
                        DynamicLinks.dynamicLinks().handleUniversalLink(url) { dynamicLink, error in
                            guard error == nil else {
                                print("Error: \(error!.localizedDescription)")
                                return
                            }

                            if let dynamicLink {
                                self.handleIncomingDynamicLink(dynamicLink)
                            }
                        }
                    }
                    .onAppear {
                        if appOpenedViaNotificationController.presentViewFromNotification == true {
                            appOpenedViaNotificationController.presentViewFromNotification = false
                            appOpenedViaNotificationController.presentViewFromNotification = true
                        }
                    }
            }
        }
    }

    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("Dynamic link was successfully received, but it has no URL.")
            return
        }

        print("Incoming link in Dynamic Link's URL property is \(url)")

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return }

        if components.path == DynamicLinkConstants.dynamicLinksEndpoint {
            if let showIdQueryItem = queryItems.first(where: { $0.name == FbConstants.showId }),
               let showId = showIdQueryItem.value {

                NotificationCenter.default.post(
                    name: .appOpenedViaShowNotificationOrDynamicLink,
                    object: nil,
                    userInfo: [FbConstants.showId: showId]
                )

            } else if let bandIdQueryItem = queryItems.first(where: { $0.name == FbConstants.bandId }),
                      let bandId = bandIdQueryItem.value {

                NotificationCenter.default.post(
                    name: .appOpenedViaBandNotificationOrDynamicLink,
                    object: nil,
                    userInfo: [FbConstants.bandId: bandId]
                )

            } else if let uidQueryItem = queryItems.first(where: { $0.name == FbConstants.uid }),
                      let uid = uidQueryItem.value {

                NotificationCenter.default.post(
                    name: .appOpenedViaUserDynamicLink,
                    object: nil,
                    userInfo: [FbConstants.uid: uid]
                )
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UITabBar.appearance().backgroundColor = .systemGroupedBackground
        
        FirebaseApp.configure()
        useFirebaseEmulator()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }

    func useFirebaseEmulator() {
        let settings = Firestore.firestore().settings
        // Using 127.0.0.1 instead of localhost because localhost causes socket error in console
        settings.host = "127.0.0.1:8080"
        settings.isPersistenceEnabled = false
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
        Storage.storage().useEmulator(withHost: "127.0.0.1", port: 9199)
        Functions.functions().useEmulator(withHost: "127.0.0.1", port: 5001)
    }
}

extension AppDelegate: MessagingDelegate {
    /// The method that delivers the FCM token to the app. It also listens for changes to the
    /// user's FCM token. This callback is fired at each app startup and whenever a new token is generated.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard !EnvironmentVariableConstants.unitTestsAreRunning,
              let fcmToken,
              !AuthController.userIsLoggedOut() else {
            return
        }

        Task {
            try? await DatabaseService.shared.updateFcmToken(to: fcmToken, forUserWithUid: AuthController.getLoggedInUid())
        }

        print("FCM Token: \(fcmToken)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let idForChatContainingMessage = userInfo[FbConstants.chatId] {
            NotificationCenter.default.post(
                name: .appOpenedViaNewMessageNotification,
                object: nil,
                userInfo: [FbConstants.chatId: idForChatContainingMessage]
            )
        }

        if let openNotificationsTab = userInfo[FbConstants.openNotificationsTab] {
            NotificationCenter.default.post(
                name: .appOpenedViaNewInviteOrApplicationNotification,
                object: nil,
                userInfo: [FbConstants.openNotificationsTab: openNotificationsTab]
            )
        }

        if let bandIdForAcceptedBandInvite = userInfo[FbConstants.bandId] {
            NotificationCenter.default.post(
                name: .appOpenedViaBandNotificationOrDynamicLink,
                object: nil,
                userInfo: [FbConstants.bandId: bandIdForAcceptedBandInvite]
            )
        }

        if let showIdForAcceptedBandInviteOrApplication = userInfo[FbConstants.showId] {
            NotificationCenter.default.post(
                name: .appOpenedViaShowNotificationOrDynamicLink,
                object: nil,
                userInfo: [FbConstants.showId: showIdForAcceptedBandInviteOrApplication]
            )
        }

        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
