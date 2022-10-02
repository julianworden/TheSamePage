//
//  BandMemberListViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/1/22.
//

import Foundation

class BandMemberListViewModel: ObservableObject {
    let band: Band
    let bandMembers: [BandMember]
    
    init(bandMembers: [BandMember], band: Band) {
        self.bandMembers = bandMembers
        self.band = band
    }
}
