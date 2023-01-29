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
final class HomeViewModel: ObservableObject {
    @Published var nearbyShows = [SearchResultHit<Show>]()
    @Published var searchRadiusInMiles: Double = 25
    
    @Published var filterConfirmationDialogIsShowing = false
    @Published var errorMessageIsShowing = false
    @Published var errorMessageText = ""
    
    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .error(let message):
                errorMessageText = message
                errorMessageIsShowing = true
            default:
                if viewState != .dataLoaded && viewState != .dataNotFound && viewState != .dataLoading {
                    errorMessageText = "Invalid View State"
                    errorMessageIsShowing = true
                }
            }
        }
    }
    
    let db = Firestore.firestore()

    var nearbyShowsListHeaderText: String {
        return "Shows within \(searchRadiusInMiles.formatted()) miles..."
    }
    
    var searchRadiusInMeters: Double {
        let milesValue = Measurement(value: searchRadiusInMiles, unit: UnitLength.miles)
        return milesValue.converted(to: UnitLength.meters).value
    }
    
    func fetchNearbyShows() async {
        guard !AuthController.userIsLoggedOut(),
              let userCoordinates = LocationController.shared.userCoordinates else {
            return
        }
        
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
                viewState = .dataLoaded
            } else {
                viewState = .dataNotFound
            }
        } catch {
            viewState = .error(message: "Failed to perform nearby shows search. System error: \(error.localizedDescription)")
        }
    }
    
    func changeSearchRadius(toValueInMiles value: Double) async {
        viewState = .dataLoading
        searchRadiusInMiles = value
        await fetchNearbyShows()
    }

    func addLocationNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(locationDataWasSet),
            name: .userLocationWasSet,
            object: nil
        )
    }

    @objc func locationDataWasSet() {
        Task {
            await fetchNearbyShows()
        }
    }
}
