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
    @Published var bandState: UsState = .AL
    @Published var userPlaysInBand = false
    @Published var userRoleInBand = Instrument.vocals
    
    @Published var imagePickerIsShowing = false
    @Published var buttonsAreDisabled = false
    /// Modified when a band is created at any time other than during onboarding
    @Published var dismissView = false
    @Published var selectedImage: UIImage?
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    let isPresentedModally: Bool
    
    @Published var viewState = ViewState.dataLoaded {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                dismissView = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }
    
    var bandToEdit: Band?
    
    init(bandToEdit: Band? = nil, isPresentedModally: Bool = false) {
        self.isPresentedModally = isPresentedModally
        
        if let bandToEdit {
            self.bandToEdit = bandToEdit
            self.bandName = bandToEdit.name
            self.bandBio = bandToEdit.bio ?? ""
            
            self.bandCity = bandToEdit.city
            
            if let bandToEditGenre = Genre(rawValue: bandToEdit.genre),
               let bandToEditState = UsState(rawValue: bandToEdit.state) {
                self.bandGenre = bandToEditGenre
                self.bandState = bandToEditState
            }
        }
    }
    
    @discardableResult func createUpdateBandButtonTapped() async -> String? {
        do {
            var newBandId: String?
            viewState = .performingWork
            bandToEdit == nil ? newBandId = try await createBand(withImage: selectedImage) : await updateBand()
            viewState = .workCompleted
            return newBandId
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }
    
    /// Creates a band object and calls the DatabaseService method to add the band to the bands Firestore collection.
    ///
    /// If the user has indicated that they are also a member of the band that they are creating, this method will call
    /// a subsequent DatabaseService method that will add the user as a BandMember to the band's members collection,
    /// and then add the user's UID to the band's memberUids array.
    /// - Parameter image: The band's profile image.
    func createBand(withImage image: UIImage?) async throws -> String {
        var newBand: Band
        var newBandId: String
        let loggedInUser = try await DatabaseService.shared.getLoggedInUser()

        newBand = Band(
            id: "",
            name: bandName,
            bio: bandBio,
            profileImageUrl: image == nil ? nil : try await DatabaseService.shared.uploadImage(image: image!),
            adminUid: loggedInUser.id,
            memberFcmTokens: [loggedInUser.fcmToken ?? ""],
            genre: bandGenre.rawValue,
            city: bandCity,
            state: bandState.rawValue
        )
        newBandId = try await DatabaseService.shared.createBand(band: newBand)

        if userPlaysInBand {
            let band = try await DatabaseService.shared.getBand(with: newBandId)
            let bandMember = BandMember(
                id: "",
                dateJoined: Date.now.timeIntervalSince1970,
                uid: loggedInUser.id,
                role: userRoleInBand.rawValue,
                username: loggedInUser.username,
                fullName: loggedInUser.fullName
            )
            try await DatabaseService.shared.addUserToBand(add: loggedInUser, as: bandMember, to: band, withBandInvite: nil)
        }

        return newBandId
    }

    func updateBand() async {
        guard let bandToEdit else {
            viewState = .error(message: "Failed to update band, please try again.")
            return
        }

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
            viewState = .error(message: error.localizedDescription)
        }
    }
}
