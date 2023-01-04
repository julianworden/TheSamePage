//
//  RootViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/24/22.
//

import Foundation

@MainActor
final class RootViewModel: ObservableObject {
    @Published var userIsLoggedOut = AuthController.userIsLoggedOut()
    @Published var selectedTab = 0
}
