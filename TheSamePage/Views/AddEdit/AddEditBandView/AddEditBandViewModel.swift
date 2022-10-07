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
    
    var bandToEdit: Band?
    
    init(bandToEdit: Band?) {
        self.bandToEdit = bandToEdit
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
            newBandId = try await DatabaseService.shared.createBand(band: newBand)
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
            newBandId = try await DatabaseService.shared.createBand(band: newBand)
        }
        
        if userPlaysInBand {
            let loggedInUsername = try await AuthController.getLoggedInUsername()
            let loggedInFullName = try await AuthController.getLoggedInFullName()
            let user = BandMember(uid: AuthController.getLoggedInUid(), role: userRoleInBand.rawValue, username: loggedInUsername, fullName: loggedInFullName)
            let band = JoinedBand(id: newBandId)
            try DatabaseService.shared.addUserToBand(user, addToBand: band, withBandInvite: nil)
        }
    }
}
