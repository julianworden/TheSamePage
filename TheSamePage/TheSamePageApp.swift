//
//  TheSamePageApp.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import FirebaseStorage
import SwiftUI

@main
struct TheSamePageApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @StateObject var loggedInUserController = LoggedInUserController()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(loggedInUserController)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UITabBar.appearance().backgroundColor = .systemGroupedBackground
        
        FirebaseApp.configure()
        
//        if ProcessInfo.processInfo.environment["testing"] == "true" {
//            let settings = Firestore.firestore().settings
//            settings.host = "localhost:8080"
//            settings.isPersistenceEnabled = false
//            settings.isSSLEnabled = false
//            Firestore.firestore().settings = settings
//            Firestore.firestore().useEmulator(withHost: "localhost", port: 8080)
//        }
        
//        Auth.auth().useEmulator(withHost:"localhost", port:9099)
//
//        Storage.storage().useEmulator(withHost:"localhost", port:9199)
        
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
}

extension AppDelegate: MessagingDelegate {
    /// The method that delivers the FCM token to the app. It also listens for changes to the
    /// user's FCM token.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("App opened from notification")
        let userInfo = response.notification.request.content.userInfo
        print("Message sent by: \(userInfo["senderName"] ?? "Unknown User")")
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
