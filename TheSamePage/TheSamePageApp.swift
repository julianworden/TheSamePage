//
//  TheSamePageApp.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

@main
struct TheSamePageApp: App {
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
