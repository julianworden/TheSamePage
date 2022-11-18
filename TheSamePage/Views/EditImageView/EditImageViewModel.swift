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
    @Published var state = ViewState.dataLoaded
    
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
    
    func updateImage(withImage image: UIImage) async throws {
        if let show {
            try await DatabaseService.shared.updateShowImage(image: image, show: show)
            return
        }
        
        if let user {
            try await DatabaseService.shared.updateUserProfileImage(image: image, user: user)
            return
        }
        
        if let band {
            try await DatabaseService.shared.updateBandProfileImage(image: image, band: band)
            return
        }
    }
}
