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
    
    /// Necessary for when this view is loaded from a ShowDetailsView
    var showParticipant: ShowParticipant?
    
    let db = Firestore.firestore()
    var bandListener: ListenerRegistration?
    
    init(band: Band? = nil, showParticipant: ShowParticipant? = nil) {
        Task {
            if let band {
                self.band = band
            }
            
            if let showParticipant {
                self.band = try await convertShowParticipantToBand(showParticipant: showParticipant)
            }
        }
    }
    
    func convertShowParticipantToBand(showParticipant: ShowParticipant) async throws -> Band {
        return try await DatabaseService.shared.convertShowParticipantToBand(showParticipant: showParticipant)
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
                                lhs.unixDateAsDate > rhs.unixDateAsDate
                            }
                            self.bandShows = sortedShows
                        } catch {
                            
                        }
                    }
                }
            }
        }
    }
    
    // TODO: Add band member listener to the band's members collection
    
    func removeListeners() {
        bandListener?.remove()
    }
}
