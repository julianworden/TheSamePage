//
//  AddEditBandViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import Foundation
import UIKit.UIImage

@MainActor
final class AddEditBandViewModel: ObservableObject {
    @Published var bandName = ""
    @Published var bandBio = ""
    @Published var bandGenre: Genre = .alternative
    @Published var bandCity = ""
    @Published var bandState: BandState = .AL
    @Published var userPlaysInBand = false
    @Published var userRoleInBand = Instrument.vocals
    
    var bandToEdit: Band?
    
    init(bandToEdit: Band?) {
        if let bandToEdit {
            self.bandToEdit = bandToEdit
            self.bandName = bandToEdit.name
            self.bandBio = bandToEdit.bio ?? ""
            
            self.bandCity = bandToEdit.city
            
            if let bandToEditGenre = Genre(rawValue: bandToEdit.genre),
               let bandToEditState = BandState(rawValue: bandToEdit.state) {
                self.bandGenre = bandToEditGenre
                self.bandState = bandToEditState
            }
        }
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
        let loggedInUser = try await DatabaseService.shared.getLoggedInUser()
        
        if let image {
            profileImageUrl = try await DatabaseService.shared.uploadImage(image: image)
            newBand = Band(
                id: "",
                name: bandName,
                bio: bandBio,
                profileImageUrl: profileImageUrl,
                adminUid: loggedInUser.id,
                memberFcmTokens: [loggedInUser.fcmToken ?? ""],
                genre: bandGenre.rawValue,
                city: bandCity,
                state: bandState.rawValue
            )
            newBandId = try await DatabaseService.shared.createBand(band: newBand)
        } else {
            newBand = Band(
                id: "",
                name: bandName,
                bio: bandBio,
                adminUid: loggedInUser.id,
                memberFcmTokens: [loggedInUser.fcmToken ?? ""],
                genre: bandGenre.rawValue,
                city: bandCity,
                state: bandState.rawValue
            )
            newBandId = try await DatabaseService.shared.createBand(band: newBand)
        }
        
        if userPlaysInBand {
            let user = try await DatabaseService.shared.getLoggedInUser()
            let band = try await DatabaseService.shared.getBand(with: newBandId)
            let bandMember = BandMember(uid: user.id, role: userRoleInBand.rawValue, username: user.username, fullName: user.fullName)
            try await DatabaseService.shared.addUserToBand(add: user, as: bandMember, to: band, withBandInvite: nil)
        }
    }
    
    func updateBand() async {
        guard let bandToEdit else { return } // TODO: Change State
        
        let updatedBand = Band(
            id: bandToEdit.id,
            name: bandName,
            bio: bandBio,
            profileImageUrl: bandToEdit.profileImageUrl,
            adminUid: bandToEdit.adminUid,
            memberUids: bandToEdit.memberUids,
            memberFcmTokens: bandToEdit.memberFcmTokens,
            genre: bandGenre.rawValue,
            city: bandCity,
            state: bandState.rawValue
        )
        
        guard bandToEdit != updatedBand else { return }
        
        do {
            try await DatabaseService.shared.updateBand(band: updatedBand)
        } catch {
            // TODO: Change state
        }
    }
}
