//
//  UserBandListViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import Foundation

class UserBandListViewModel: ObservableObject {
    
    var bands = [Band]()
    
    init(bands: [Band]) {
        self.bands = bands
    }
}
