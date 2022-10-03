//
//  BandProfileViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/24/22.
//

import Foundation

@MainActor
class BandProfileViewModel: ObservableObject {
    @Published var bandName: String
    @Published var bandBio: String?
    @Published var bandCity: String
    @Published var bandState: String
    @Published var bandProfileImageUrl: String?
    @Published var bandGenre: String
    @Published var bandLinks = [PlatformLink]()
    @Published var bandMembers = [BandMember]()
    
    let band: Band
    
    init(band: Band) {
        self.band = band
        self.bandName = band.name
        self.bandBio = band.bio
        self.bandCity = band.city
        self.bandState = band.state
        self.bandGenre = band.genre
        self.bandProfileImageUrl = band.profileImageUrl
        
        Task {
            bandMembers = try await DatabaseService.shared.getBandMembers(forBand: band)
            bandLinks = try await DatabaseService.shared.getBandLinks(forBand: band)
        }
    }
}
