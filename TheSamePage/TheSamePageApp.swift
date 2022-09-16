//
//  TheSamePageApp.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

@main
struct TheSamePageApp: App {
    @StateObject var showsViewModel = ShowsViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(showsViewModel)
        }
    }
}
