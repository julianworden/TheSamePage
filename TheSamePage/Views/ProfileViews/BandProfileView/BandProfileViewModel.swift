//
//  BandProfileViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/24/22.
//

import Foundation

@MainActor
class BandProfileViewModel: ObservableObject {
    @Published var bandName: String?
    @Published var bandBio: String?
    @Published var bandCity: String?
    @Published var bandState: String?
    @Published var bandProfileImageUrl: String?
    @Published var bandGenre: String?
    @Published var bandLinks = [PlatformLink]()
    @Published var bandMembers = [BandMember]()
    @Published var loggedInUserIsBandAdmin: Bool?

    var band: Band?
    /// Necessary for when this view is loaded from a ShowDetailsView
    var showParticipant: ShowParticipant?
    
    init(band: Band?, showParticipant: ShowParticipant?) {
        Task {
            if let band {
                self.band = band
                try await initializeBand(band: band)
            }
            
            if let showParticipant {
                self.band = try await convertShowParticipantToBand(showParticipant: showParticipant)
                
                if self.band != nil {
                    try await initializeBand(band: self.band!)
                }
            }
        }
    }
    
    func convertShowParticipantToBand(showParticipant: ShowParticipant) async throws -> Band {
        return try await DatabaseService.shared.convertShowParticipantToBand(showParticipant: showParticipant)
    }
    
    func setupView() async throws {
        if band != nil && showParticipant == nil {
            try await initializeBand(band: band!)
        } else if band == nil && showParticipant != nil {
            let convertedBand = try await DatabaseService.shared.convertShowParticipantToBand(showParticipant: showParticipant!)
            try await initializeBand(band: convertedBand)
        }
    }
//
    func initializeBand(band: Band) async throws {
        self.bandName = band.name
        self.bandBio = band.bio
        self.bandCity = band.city
        self.bandState = band.state
        self.bandGenre = band.genre
        self.bandProfileImageUrl = band.profileImageUrl
        self.loggedInUserIsBandAdmin = band.loggedInUserIsBandAdmin
        self.bandMembers = try await DatabaseService.shared.getBandMembers(forBand: band)
        self.bandLinks = try await DatabaseService.shared.getBandLinks(forBand: band)
    }
}
