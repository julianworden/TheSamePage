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
    
    /// Creates a band object and calls the DatabaseService method to add the band to the bands Firestore collection.
    ///
    /// If the user has indicated that they are also a member of the band that they are creating, this method will call
    /// a subsequent DatabaseService method that will add the user as a BandMember to the band's members collection,
    /// and then add the user's UID to the band's memberUids array.
    /// - Parameter image: The band's profile image.
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
                memberUids: [],
                genre: bandGenre.rawValue,
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
                memberUids: [],
                genre: bandGenre.rawValue,
                city: bandCity,
                state: bandState.rawValue
            )
            newBandId = try await DatabaseService.shared.createBand(band: newBand)
        }
        
        if userPlaysInBand {
            let loggedInUsername = try await AuthController.getLoggedInUsername()
            let loggedInFullName = try await AuthController.getLoggedInFullName()
            let bandMember = BandMember(uid: AuthController.getLoggedInUid(), role: userRoleInBand.rawValue, username: loggedInUsername, fullName: loggedInFullName)
            try await DatabaseService.shared.addUserToBand(add: bandMember, toBandWithId: newBandId, withBandInvite: nil)
        }
    }
}
