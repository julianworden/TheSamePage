//
//  BandProfileHeaderViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import Foundation

class BandProfileHeaderViewModel: ObservableObject {
    let bandName: String
    let bandBio: String?
    let bandGenre: String
    let bandCity: String
    let bandState: String
    let bandImageUrl: String?
    
    init(band: Band) {
        self.bandName = band.name
        self.bandBio = band.bio
        self.bandGenre = band.genre
        self.bandCity = band.city
        self.bandState = band.state
        self.bandImageUrl = band.profileImageUrl
    }
}
