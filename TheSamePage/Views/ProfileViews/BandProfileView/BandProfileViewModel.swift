//
//  BandProfileViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/24/22.
//

import FirebaseFirestore
import Foundation
import SwiftUI
import UIKit.UIImage

@MainActor
class BandProfileViewModel: ObservableObject {
    @Published var band: Band?
    @Published var bandLinks = [PlatformLink]()
    @Published var bandMembers = [BandMember]()
    @Published var bandShows = [Show]()
    @Published var selectedTab = SelectedBandProfileTab.about

    @Published var bandWasDeleted = false
    @Published var addEditLinkSheetIsShowing = false
    @Published var addBandMemberSheetIsShowing = false
    @Published var editImageViewIsShowing = false
    @Published var editImageConfirmationDialogIsShowing = false
    @Published var deleteImageConfirmationAlertIsShowing = false

    @Published var bandImage: Image?
    @Published var updatedImage: UIImage?

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    let isPresentedModally: Bool

    var shortenedDynamicLink: URL?
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            case .dataDeleted:
                bandWasDeleted = true
            default:
                if viewState != .dataLoaded && viewState != .dataLoading {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }

    var shouldShowMenu: Bool {
        guard let band else { return false }

        return band.loggedInUserIsNotInvolvedWithBand ||
               band.loggedInUserIsBandAdmin
    }

    init(
        band: Band?,
        showParticipant: ShowParticipant? = nil,
        bandId: String? = nil,
        isPresentedModally: Bool = false
    ) {
        self.isPresentedModally = isPresentedModally

        if let band {
            Task {
                self.band = band
                await callOnAppearMethods()
                viewState = .dataLoaded
                return
            }
        }

        if let showParticipant {
            Task {
                self.band = await convertShowParticipantToBand(showParticipant: showParticipant)
                await callOnAppearMethods()
                viewState = .dataLoaded
                return
            }
        }

        if let bandId {
            Task {
                self.band = await getBand(withId: bandId)
                await callOnAppearMethods()
                viewState = .dataLoaded
                return
            }
        }
    }
    
    func convertShowParticipantToBand(showParticipant: ShowParticipant) async -> Band? {
        do {
            viewState = .dataLoading

            return try await DatabaseService.shared.convertShowParticipantToBand(showParticipant: showParticipant)
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }

    func callOnAppearMethods() async {
        if band != nil {
            await getLatestBandData()
            await getBandMembers()
            await getBandLinks()
            await getBandShows()
            await createDynamicLinkForBand()
        }
    }

    func getBand(withId id: String) async -> Band? {
        do {
            viewState = .dataLoading

            return try await DatabaseService.shared.getBand(with: id)
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }

    func getLatestBandData() async {
        guard let band else {
            viewState = .error(message: ErrorMessageConstants.failedToFetchBand)
            return
        }

        do {
            self.band = try await DatabaseService.shared.getBand(with: band.id)
        } catch FirebaseError.dataDeleted {
            viewState = .dataDeleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getBandMembers() async {
        guard let band else {
            viewState = .error(message: ErrorMessageConstants.failedToFetchBand)
            return
        }

        do {
            self.bandMembers = try await DatabaseService.shared.getBandMembers(forBand: band)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func removeBandMemberFromBand(bandMember: BandMember) async {
        guard let band else {
            viewState = .error(message: ErrorMessageConstants.failedToFetchBand)
            return
        }

        do {
            let bandMemberAsUser = try await DatabaseService.shared.convertBandMemberToUser(bandMember: bandMember)
            try await DatabaseService.shared.removeUserFromBand(remove: bandMemberAsUser, as: bandMember, from: band)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getBandLinks() async {
        guard let band else {
            viewState = .error(message: ErrorMessageConstants.failedToFetchBand)
            return
        }

        do {
            self.bandLinks = try await DatabaseService.shared.getBandLinks(forBand: band)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getBandShows() async {
        guard let band else {
            viewState = .error(message: ErrorMessageConstants.failedToFetchBand)
            return
        }

        do {
            let fetchedShows = try await DatabaseService.shared.getShowsForBand(band: band)
            let sortedShows = fetchedShows.sorted { lhs, rhs in
                lhs.date.unixDateAsDate > rhs.date.unixDateAsDate
            }
            self.bandShows = sortedShows
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func deleteBandImage() async {
        guard let band else {
            viewState = .error(message: ErrorMessageConstants.failedToFetchBand)
            return
        }

        do {
            try await DatabaseService.shared.deleteBandImage(forBand: band)
            bandImage = nil
            updatedImage = nil
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func deleteBandLink(_ link: PlatformLink) async {
        guard let band else {
            viewState = .error(message: ErrorMessageConstants.failedToFetchBand)
            return
        }

        do {
            try await DatabaseService.shared.deleteBandLink(band: band, link: link)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func createDynamicLinkForBand() async {
        guard let band else {
            print("Band object cannot be nil before generating Dynamic Link for band.")
            return
        }

        shortenedDynamicLink = await DynamicLinkController.shared.createDynamicLink(ofType: .band, for: band)
    }
}
