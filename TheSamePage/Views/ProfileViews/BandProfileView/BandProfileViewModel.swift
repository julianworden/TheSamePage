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

    @Published var addEditLinkSheetIsShowing = false
    @Published var addBandMemberSheetIsShowing = false
    @Published var sendShowInviteViewIsShowing = false
    @Published var editImageViewIsShowing = false
    @Published var bandSettingsViewIsShowing = false
    @Published var addEditBandSheetIsShowing = false
    @Published var editImageConfirmationDialogIsShowing = false
    @Published var deleteImageConfirmationAlertIsShowing = false
    @Published var bandMemberSheetIsShowing = false
    @Published var showDetailsViewIsShowing = false

    @Published var bandImage: Image?
    @Published var updatedImage: UIImage?

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                if viewState != .dataLoaded && viewState != .dataLoading {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }
    let isPresentedModally: Bool
    
    let db = Firestore.firestore()
    var bandListener: ListenerRegistration?
    
    init(band: Band? = nil, showParticipant: ShowParticipant? = nil, isPresentedModally: Bool = false) {
        self.isPresentedModally = isPresentedModally

        if let band {
            self.band = band
            viewState = .dataLoaded
            return
        }

        if let showParticipant {
            Task {
                self.band = await convertShowParticipantToBand(showParticipant: showParticipant)
                viewState = .dataLoaded
            }
        }
    }
    
    func convertShowParticipantToBand(showParticipant: ShowParticipant) async -> Band? {
        viewState = .dataLoading
        
        do {
            return try await DatabaseService.shared.convertShowParticipantToBand(showParticipant: showParticipant)
        } catch {
            viewState = .error(message: error.localizedDescription)
            return nil
        }
    }

    func callOnAppearMethods() async {
        await getLatestBandData()
        await getBandMembers()
        await getBandLinks()
        await getBandShows()
    }

    func getLatestBandData() async {
        guard let band else { return }

        do {
            self.band = try await DatabaseService.shared.getBand(with: band.id)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }


    func getBandMembers() async {
        guard let band else { return }

        do {
            self.bandMembers = try await DatabaseService.shared.getBandMembers(forBand: band)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getBandLinks() async {
        guard let band else { return }

        do {
            self.bandLinks = try await DatabaseService.shared.getBandLinks(forBand: band)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getBandShows() async {
        guard let band else { return }

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
        guard let band else { return }

        do {
            try await DatabaseService.shared.deleteBandImage(forBand: band)
            bandImage = nil
            updatedImage = nil
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func removeListeners() {
        bandListener?.remove()
    }
}
