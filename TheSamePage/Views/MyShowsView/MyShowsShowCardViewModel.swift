//
//  MyShowsShowCardViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import Foundation

class MyShowsShowCardViewModel: ObservableObject {
    let show: Show

    init(show: Show) {
        self.show = show
    }
}
