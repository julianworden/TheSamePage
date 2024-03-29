//
//  EditImageViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/23/22.
//

import Foundation
import UIKit.UIImage

@MainActor
final class EditImageViewModel: ObservableObject {
    @Published var imagePickerIsShowing = false
    @Published var toolbarButtonsDisabled = false
    @Published var imageUpdateIsComplete = false
    
    @Published var errorAlertIsShowing = false
    @Published var errorAlertText = ""
    
    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                toolbarButtonsDisabled = true
            case .workCompleted:
                imageUpdateIsComplete = true
            case .error(let message):
                toolbarButtonsDisabled = false
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                print("Unknown viewState set in EditImageViewModel")
            }
        }
    }
    
    var show: Show?
    var user: User?
    var band: Band?

    init(show: Show? = nil, user: User? = nil, band: Band? = nil) {
        if let show {
            self.show = show
            return
        }
        
        if let user {
            self.user = user
            return
        }
        
        if let band {
            self.band = band
            return
        }
    }
    
    func updateImage(withImage image: UIImage) async -> String? {
        do {
            viewState = .performingWork
            
            if let show {
                let updatedImageUrl = try await DatabaseService.shared.updateShowImage(image: image, show: show)
                viewState = .workCompleted
                return updatedImageUrl
            }
            
            if let user {
                let updatedImageUrl = try await DatabaseService.shared.updateUserProfileImage(image: image, user: user)
                viewState = .workCompleted
                return updatedImageUrl
            }
            
            if let band {
                let updatedImageUrl = try await DatabaseService.shared.updateBandProfileImage(image: image, band: band)
                viewState = .workCompleted
                return updatedImageUrl
            }

            return nil
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }
}
