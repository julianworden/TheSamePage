//
//  AddEditBandViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import Foundation
import UIKit.UIImage

class AddEditBandViewModel: ObservableObject {
    @Published var bandName = ""
    @Published var bandGenre = ""
    @Published var bandCity = ""
    @Published var bandState = ""
    @Published var userPlaysInBand = false
    
    func createBand(withImage image: UIImage?) async throws -> Band {
        var newBand: Band
        // TODO: Add admin to members list if they play in band
        if let image {
            let profileImageUrl = try await DatabaseService.shared.uploadImage(image: image)
            newBand = Band(
                name: bandName,
                profileImageUrl: profileImageUrl,
                admin: AuthController.getLoggedInUid(),
                members: [],
                genre: "",
                links: nil,
                shows: nil,
                city: bandCity,
                state: bandState
            )
        } else {
            newBand = Band(
                name: bandName,
                profileImageUrl: nil,
                admin: AuthController.getLoggedInUid(),
                members: [],
                genre: "",
                links: nil,
                shows: nil,
                city: bandCity,
                state: bandState
            )
        }
        
        try DatabaseService.shared.createBand(band: newBand)
        return newBand
    }
}
