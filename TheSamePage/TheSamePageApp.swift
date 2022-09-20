//
//  TheSamePageApp.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseCore
import SwiftUI

@main
struct SO62626652_AppDelegateAdaptorApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @StateObject var showsController = ShowsController()
    @StateObject var userController = UserController()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(showsController)
                .environmentObject(userController)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UITabBar.appearance().backgroundColor = .white
        return true
    }
}
