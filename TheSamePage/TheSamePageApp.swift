//
//  TheSamePageApp.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseCore
import SwiftUI

@main
struct TheSamePageApp: App {
    @StateObject var showsController = ShowsController()
    @StateObject var userController = UserController()
    
    init() {
        FirebaseApp.configure()
        UITabBar.appearance().backgroundColor = .white
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(showsController)
                .environmentObject(userController)
        }
    }
}
