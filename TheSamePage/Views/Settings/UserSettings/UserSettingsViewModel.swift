//
//  UserSettingsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/29/23.
//

import Foundation

@MainActor
final class UserSettingsViewModel: ObservableObject {
    @Published var reauthenticateViewSheetIsShowing = false
}
