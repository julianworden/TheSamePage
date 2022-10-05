//
//  SearchResultRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import Foundation

class SearchResultRowViewModel: ObservableObject {
    var band: Band?
    var user: User?
    var show: Show?
    
    init(band: Band?, user: User?, show: Show?) {
        self.band = band
        self.user = user
        self.show = show
    }
}
