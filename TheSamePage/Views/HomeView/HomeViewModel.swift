//
//  HomeViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/17/22.
//

import CoreLocation
import FirebaseFirestore
import Foundation
import Typesense

@MainActor
class HomeViewModel: ObservableObject {
    enum HomeViewModelError: Error {
        case locationController(message: String)
    }
    
    @Published var nearbyShows = [SearchResultHit<Show>]()
    @Published var searchRadiusInMiles: Double = 25
    @Published var state = ViewState.dataLoading
    
    let db = Firestore.firestore()
    var userCoordinates: CLLocationCoordinate2D?
    
    var nearbyShowsListHeaderText: String {
        return "Shows within \(searchRadiusInMiles.formatted()) miles..."
    }
    
    var searchRadiusInMeters: Double {
        let milesValue = Measurement(value: searchRadiusInMiles, unit: UnitLength.miles)
        return milesValue.converted(to: UnitLength.meters).value
    }
    
    func fetchNearbyShows() async throws {
        guard let userCoordinates = LocationController.shared.userCoordinates else { return }
        
        let searchParameters = SearchParameters(
            q: "*",
            queryBy: "name",
            filterBy: "typesenseCoordinates:(\(userCoordinates.latitude), \(userCoordinates.longitude), \(searchRadiusInMiles) mi)",
            sortBy: "typesenseCoordinates(\(userCoordinates.latitude), \(userCoordinates.longitude)):asc"
        )
        
        do {
            let (data, _) = try await TypesenseController.client.collection(name: FbConstants.shows).documents().search(searchParameters, for: Show.self)
            if let fetchedNearbyShows = data?.hits,
               !fetchedNearbyShows.isEmpty {
                nearbyShows = fetchedNearbyShows
                state = .dataLoaded
            } else {
                state = .dataNotFound
            }
        } catch {
//            throw SearchViewModelError.searchFailed(message: "User search failed")
        }
    }
    
    func changeSearchRadius(toValue value: Double) {
        state = .dataLoading
        searchRadiusInMiles = value
        Task {
            try await fetchNearbyShows()
        }
    }
}
