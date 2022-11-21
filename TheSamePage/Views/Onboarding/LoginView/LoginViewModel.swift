//
//  LoginViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var emailAddress = ""
    @Published var password = ""
    
    @Published var loginErrorShowing = false
    @Published var loginErrorMessage = ""
    @Published var loginButtonIsDisabled = false
    @Published var userIsOnboarding = true
    
    func userIsOnboardingAfterLoginWith(emailAddress: String, password: String) async {
        do {
            loginButtonIsDisabled = true
            try await Auth.auth().signIn(withEmail: emailAddress, password: password)
            userIsOnboarding = false
        } catch {
            loginErrorMessage = error.localizedDescription
            loginErrorShowing = true
            loginButtonIsDisabled = false
            userIsOnboarding = true
        }
    }
}
