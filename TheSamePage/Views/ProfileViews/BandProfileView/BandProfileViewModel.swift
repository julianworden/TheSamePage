//
//  BandProfileViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/24/22.
//

import FirebaseFirestore
import Foundation

@MainActor
class BandProfileViewModel: ObservableObject {
    @Published var band: Band?
    @Published var bandLinks = [PlatformLink]()
    @Published var bandMembers = [BandMember]()
    @Published var bandShows = [Show]()
    @Published var selectedTab = SelectedBandProfileTab.about
    
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
                    print("Unknown viewState passed to OtherUserProfileViewModel: \(viewState)")
                }
            }
        }
    }
    
    /// Necessary for when this view is loaded from a ShowDetailsView
    var showParticipant: ShowParticipant?
    
    let db = Firestore.firestore()
    var bandListener: ListenerRegistration?
    
    init(band: Band? = nil, showParticipant: ShowParticipant? = nil) {
        Task {
            if let band {
                self.band = band
            }
            
            if let showParticipant,
               let convertedBand = await convertShowParticipantToBand(showParticipant: showParticipant) {
                self.band = convertedBand
            }
            
            if self.band != nil {
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
    
    func addBandListener() {
        guard let band else { return }
        
        bandListener = db.collection(FbConstants.bands).document(band.id).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let band = try? snapshot!.data(as: Band.self) {
                    self.band = band
                    Task {
                        do {
                            self.bandMembers = try await DatabaseService.shared.getBandMembers(forBand: band)
                            self.bandLinks = try await DatabaseService.shared.getBandLinks(forBand: band)
                            let fetchedShows = try await DatabaseService.shared.getShowsForBand(band: band)
                            let sortedShows = fetchedShows.sorted { lhs, rhs in
                                lhs.date.unixDateAsDate > rhs.date.unixDateAsDate
                            }
                            self.bandShows = sortedShows
                        } catch {
                            self.viewState = .error(message: error.localizedDescription)
                        }
                    }
                }
            } else if error != nil {
                self.viewState = .error(message: "There was an error fetching this band's info. System error: \(error!.localizedDescription)")
            }
        }
    }
    
    // TODO: Add band member listener to the band's members collection
    
    func removeListeners() {
        bandListener?.remove()
    }
}
