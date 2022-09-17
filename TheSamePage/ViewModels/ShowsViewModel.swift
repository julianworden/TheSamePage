//
//  ShowsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

class ShowsViewModel: ObservableObject {
    @Published var showsNearYou = [Show]()
    @Published var yourShows = [Show]()
    
    func getShows() {
        showsNearYou = DatabaseService.shows
        yourShows = DatabaseService.shows
    }
}
