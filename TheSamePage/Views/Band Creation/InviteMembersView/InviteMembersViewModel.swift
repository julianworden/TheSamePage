//
//  InviteMembersViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/22/22.
//

import Foundation

class InviteMembersViewModel: ObservableObject {
    let band: Band?
    
    init(band: Band?) {
        self.band = band
    }
}
