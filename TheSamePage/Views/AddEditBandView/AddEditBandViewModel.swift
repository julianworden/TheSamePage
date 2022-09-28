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
    @Published var bandBio = ""
    @Published var bandGenre: Genre = .alternative
    @Published var bandCity = ""
    @Published var bandState: BandState = .AL
    @Published var userPlaysInBand = false
    @Published var userRoleInBand = Instrument.vocals
    
    var createdBand: Band?
    
    init(band: Band?) {
        self.createdBand = band
    }
    
    func createBand(withImage image: UIImage?) async throws {
        var newBand: Band
        var newBandId: String
        var profileImageUrl: String?
        if let image {
            profileImageUrl = try await DatabaseService.shared.uploadImage(image: image)
            newBand = Band(
                name: bandName,
                bio: bandBio,
                profileImageUrl: profileImageUrl,
                adminUid: AuthController.getLoggedInUid(),
                members: nil,
                genre: bandGenre.rawValue,
                links: nil,
                shows: nil,
                city: bandCity,
                state: bandState.rawValue
            )
            newBandId = try DatabaseService.shared.createBand(band: newBand)
        } else {
            newBand = Band(
                name: bandName,
                bio: bandBio,
                profileImageUrl: nil,
                adminUid: AuthController.getLoggedInUid(),
                members: nil,
                genre: bandGenre.rawValue,
                links: nil,
                shows: nil,
                city: bandCity,
                state: bandState.rawValue
            )
            newBandId = try DatabaseService.shared.createBand(band: newBand)
        }
        
        if userPlaysInBand {
            let loggedInUserName = try await AuthController.getLoggedInUserName()
            let user = BandMember(uid: AuthController.getLoggedInUid(), role: userRoleInBand.rawValue, name: loggedInUserName)
            let band = JoinedBand(id: newBandId)
            try DatabaseService.shared.addUserToBand(user, addToBand: band, withBandInvite: nil)
        }
        
        // Done this way because the band that's returned needs to have an id property
        createdBand = Band(
            id: newBandId,
            name: bandName,
            bio: bandBio,
            profileImageUrl: profileImageUrl,
            adminUid: AuthController.getLoggedInUid(),
            members: nil,
            genre: bandGenre.rawValue,
            links: nil,
            shows: nil,
            city: bandCity,
            state: bandState.rawValue
        )
    }
}
