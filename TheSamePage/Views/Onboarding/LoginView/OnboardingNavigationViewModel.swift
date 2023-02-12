//
//  OnboardingNavigationViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/12/23.
//

import Foundation

@MainActor
final class OnboardingNavigationViewModel: ObservableObject {
    @Published var navigationPath = [OnboardingScreen]()

    func navigateToSignUpView() {
        navigationPath.append(.signUpView)
    }

    func navigateToCreateUsernameView() {
        navigationPath.append(.createUsernameView)
    }

    func popToRoot() {
        navigationPath = []
    }
}
