//
//  BandLinkListViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import Foundation

class BandLinkListViewModel: ObservableObject {
    @Published var bandLinks = [Link]()
    
    init(bandLinks: [Link]) {
        self.bandLinks = bandLinks
    }
}
