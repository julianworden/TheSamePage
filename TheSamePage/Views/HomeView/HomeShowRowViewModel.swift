//
//  HomeShowRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/26/22.
//

import Foundation

class HomeShowRowViewModel: ObservableObject {
    let show: Show
    
    init(show: Show) {
        self.show = show
    }
}
