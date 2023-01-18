//
//  UserViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import UIKit.UIImage

@MainActor
class LoggedInUserController: ObservableObject {
    @Published var loggedInUser: User?
    @Published var bands = [Band]()
    
    /// The image loaded from the ProfileAsyncImage in LoggedInUserProfileView
    @Published var userImage: Image?
    /// A new image set within EditImageView
    @Published var updatedImage: UIImage?
    
    @Published var errorMessageShowing = false
    @Published var errorMessageText = ""
    
    @Published var loggedInUserProfileViewState = ViewState.displayingView {
        didSet {
            switch loggedInUserProfileViewState {
            case .error(let message):
                errorMessageText = message
                errorMessageShowing = true
            default:
                print("Unknown viewState passed to LoggedInUserController: \(loggedInUserProfileViewState)")
            }
        }
    }
    
    let db = Firestore.firestore()

    func getLoggedInUserInfo() async {
        guard !AuthController.userIsLoggedOut() else { return }

        do {
            self.loggedInUser = try await DatabaseService.shared.getLoggedInUser()
            self.bands = try await DatabaseService.shared.getBands(withUid: loggedInUser!.id)
        } catch {
            loggedInUserProfileViewState = .error(message: error.localizedDescription)
        }
    }
    
    func logOut() {
        self.loggedInUser = nil
        self.bands = []

        do {
            try AuthController.logOut()
        } catch {
            loggedInUserProfileViewState = .error(message: error.localizedDescription)
        }
    }
}
