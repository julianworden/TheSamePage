//
//  ShowsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import Foundation

final class ShowsController: ObservableObject {
    // TODO: Migrate the rest of these methods and properties to MyShowsViewModel
    
    @Published var nearbyShows = [Show]()
    
    let db = Firestore.firestore()
    
    func getShows() {
        nearbyShows = DatabaseService.shows
    }
    
    /// Fetches shows closest to the user based on their distance filter settings.
    func getShowsNearYou() {
        nearbyShows = DatabaseService.shared.getShowsNearYou()
    }
}
