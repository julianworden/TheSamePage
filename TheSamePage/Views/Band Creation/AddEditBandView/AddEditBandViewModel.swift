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
        var newBandId: String
        var profileImageUrl: String?
        // TODO: Add admin to members list if they play in band
        if let image {
            profileImageUrl = try await DatabaseService.shared.uploadImage(image: image)
            newBand = Band(
                name: bandName,
                profileImageUrl: profileImageUrl,
                adminUid: AuthController.getLoggedInUid(),
                members: [],
                genre: "",
                links: nil,
                shows: nil,
                city: bandCity,
                state: bandState
            )
            newBandId = try DatabaseService.shared.createBand(band: newBand)
        } else {
            newBand = Band(
                name: bandName,
                profileImageUrl: nil,
                adminUid: AuthController.getLoggedInUid(),
                members: [],
                genre: "",
                links: nil,
                shows: nil,
                city: bandCity,
                state: bandState
            )
            newBandId = try DatabaseService.shared.createBand(band: newBand)
        }
        // Done this way because the band that's returned needs to have an id property
        return Band(
            id: newBandId,
            name: bandName,
            profileImageUrl: profileImageUrl,
            adminUid: AuthController.getLoggedInUid(),
            members: [],
            genre: "",
            links: nil,
            shows: nil,
            city: bandCity,
            state: bandState
        )
    }
}
