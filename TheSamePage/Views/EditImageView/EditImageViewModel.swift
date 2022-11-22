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
    @Published var editButtonIsDisabled = false
    @Published var imageUpdateIsComplete = false
    
    @Published var errorAlertIsShowing = false
    @Published var errorAlertText = ""
    
    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                editButtonIsDisabled = true
            case .workCompleted:
                imageUpdateIsComplete = true
            case .error(let message):
                editButtonIsDisabled = false
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
    var imageUrl: String?
    
    init(show: Show? = nil, user: User? = nil, band: Band? = nil) {
        if let show {
            self.show = show
            self.imageUrl = show.imageUrl
            return
        }
        
        if let user {
            self.user = user
            self.imageUrl = user.profileImageUrl
            return
        }
        
        if let band {
            self.band = band
            self.imageUrl = band.profileImageUrl
            return
        }
    }
    
    func updateImage(withImage image: UIImage) async {
        do {
            viewState = .performingWork
            
            if let show {
                try await DatabaseService.shared.updateShowImage(image: image, show: show)
            }
            
            if let user {
                try await DatabaseService.shared.updateUserProfileImage(image: image, user: user)
            }
            
            if let band {
                try await DatabaseService.shared.updateBandProfileImage(image: image, band: band)
            }
            
            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
