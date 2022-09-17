//
//  ProfileBandCardViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/17/22.
//

import Foundation

class ProfileBandCardViewModel: ObservableObject {
    @Published var band: Band
    
    init(band: Band) {
        self.band = band
    }
}
