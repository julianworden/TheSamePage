//
//  ShowsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import Foundation

class ShowsViewModel: ObservableObject {
    @Published var shows = [Show]()
    
    func getShows() {
        shows = DatabaseService.shows
    }
}
