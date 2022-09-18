//
//  ShowsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

class ShowsController: ObservableObject {
    @Published var showsNearYou = [Show]()
    @Published var yourShows = [Show]()
    
    func getShows() {
        showsNearYou = DatabaseService.shows
        // TODO: Implement showsNearYou = DatabaseService.getShowsNearYou() and remove above line
        yourShows = DatabaseService.shows
    }
    
    /// Fetches shows closest to the user based on their distance filter settings.
    func getShowsNearYou() {
        showsNearYou = DatabaseService.getShowsNearYou()
    }
    
    /// Fetches all shows that the user is either the host of or is participating in.
    func getYourShows() {
        
    }
}
