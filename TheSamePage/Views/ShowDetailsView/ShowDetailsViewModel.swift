//
//  ShowDetailsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import Foundation

class ShowDetailsViewModel: ObservableObject {
    @Published var show: Show
    
    init(show: Show) {
        self.show = show
    }
}
