//
//  UserSettingsNavigationViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/31/23.
//

import Foundation

@MainActor
final class UserSettingsNavigationViewModel: ObservableObject {
    @Published var navigationPath = [UserSettingsScreen]()

    func navigateToReauthenticationView() {
        navigationPath.append(.reauthenticateView)
    }

    func navigateToEditUserInfoView() {
        navigationPath.append(.editUserInfoView)
    }

    func navigateToChangeEmailAddressView() {
        navigationPath.append(.changeEmailAddressView)
    }

    func navigateToChangePasswordView() {
        navigationPath.append(.changePasswordView)
    }

    func navigateToChangeUsernameView() {
        navigationPath.append(.changeUsernameView)
    }

    func navigateToDeleteAccountView() {
        navigationPath.append(.deleteAccountView)
    }

    func popToRoot() {
        navigationPath = []
    }
}
