//
//  HomeShowCardViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

class HomeShowCardViewModel: ObservableObject {
    let show: Show
    
    init(show: Show) {
        self.show = show
    }
}
