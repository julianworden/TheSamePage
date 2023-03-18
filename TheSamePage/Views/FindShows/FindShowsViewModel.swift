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
final class FindShowsViewModel: ObservableObject {
    @Published var upcomingFetchedShows = [Show]()
    @Published var searchRadiusInMiles: Double = 25
    var searchingState: String?
    @Published var isSearchingByState = false
    @Published var isSearchingByDistance = false
    
    @Published var errorMessageIsShowing = false
    @Published var errorMessageText = ""
    @Published var userHasGivenLocationPermission = false
    var locationAuthorizationStatus = CLAuthorizationStatus.notDetermined
    
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

    var fetchedShowsListHeaderText: String {
        if isSearchingByDistance && !isSearchingByState {
            return "Upcoming shows within \(searchRadiusInMiles.formatted()) miles"
        } else if isSearchingByState &&
                  !isSearchingByDistance,
                  let searchingState {
            return "Upcoming shows in \(searchingState)"
        } else {
            return "Results."
        }
    }

    var noDataFoundText: String {
        if isSearchingByDistance && !isSearchingByState {
            return "We can't find any upcoming shows within \(searchRadiusInMiles.formatted()) miles of your current location. You can tap the button above to widen your search radius."
        } else if isSearchingByState &&
                  !isSearchingByDistance,
                  let searchingState {
            return "We can't find any upcoming shows in \(searchingState)."
        } else {
            return NoDataFoundConstants.noShowsFoundGeneric
        }
    }
    
    var searchRadiusInMeters: Double {
        let milesValue = Measurement(value: searchRadiusInMiles, unit: UnitLength.miles)
        return milesValue.converted(to: UnitLength.meters).value
    }

    var userHasAuthorizedLocationPermission: Bool {
        switch locationAuthorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .restricted, .denied, .notDetermined:
            return false
        @unknown default:
            return false
        }
    }
    
    func fetchNearbyShows() async {
        guard !AuthController.userIsLoggedOut(),
              let userCoordinates = LocationController.shared.userCoordinates else {
            viewState = .error(message: ErrorMessageConstants.failedToPerformShowSearch)
            return
        }

        isSearchingByDistance = true
        isSearchingByState = false
        
        await performShowSearchWithCoordinates(userCoordinates)
    }

    func fetchShows(in state: String) async {
        guard !AuthController.userIsLoggedOut() else {
            viewState = .error(message: ErrorMessageConstants.failedToPerformShowSearch)
            return
        }
        
        viewState = .dataLoading
        self.searchingState = state
        isSearchingByState = true
        isSearchingByDistance = false

        await performShowSearchInState(state: state)
    }

    func performShowSearchWithCoordinates(_ userCoordinates: CLLocationCoordinate2D) async {
        let searchParameters = SearchParameters(
            q: "*",
            queryBy: "name",
            filterBy: "typesenseCoordinates:(\(userCoordinates.latitude), \(userCoordinates.longitude), \(searchRadiusInMiles) mi)",
            sortBy: "typesenseCoordinates(\(userCoordinates.latitude), \(userCoordinates.longitude)):asc"
        )

        do {
            let (data, _) = try await TypesenseController.client.collection(name: FbConstants.shows).documents().search(searchParameters, for: Show.self)
            if let fetchedNearbyShows = data?.hits {
                var upcomingFetchedShows = [Show]()

                for show in fetchedNearbyShows {
                    if let show = show.document,
                       !show.alreadyHappened {
                        upcomingFetchedShows.append(show)
                    }
                }

                self.upcomingFetchedShows = upcomingFetchedShows.sorted { $0.date.unixDateAsDate < $1.date.unixDateAsDate }
                upcomingFetchedShows.isEmpty ? (viewState = .dataNotFound) : (viewState = .dataLoaded)
            }
        } catch {
            viewState = .error(message: "Failed to perform shows search. System error: \(error.localizedDescription)")
        }
    }

    func performShowSearchInState(state: String) async {
        let searchParameters = SearchParameters(
            q: "*",
            queryBy: "state",
            filterBy: "state:\(state)"
        )

        do {
            let (data, _) = try await TypesenseController.client.collection(name: FbConstants.shows).documents().search(searchParameters, for: Show.self)
            if let fetchedNearbyShows = data?.hits {
                var upcomingFetchedShows = [Show]()

                for show in fetchedNearbyShows {
                    if let show = show.document,
                       !show.alreadyHappened {
                        upcomingFetchedShows.append(show)
                    }
                }

                self.upcomingFetchedShows = upcomingFetchedShows.sorted { $0.date.unixDateAsDate < $1.date.unixDateAsDate }
                upcomingFetchedShows.isEmpty ? (viewState = .dataNotFound) : (viewState = .dataLoaded)
            }
        } catch {
            viewState = .error(message: "Failed to perform shows search. System error: \(error.localizedDescription)")
        }
    }

    func changeSearchRadius(toValueInMiles value: Double) async {
        viewState = .dataLoading
        isSearchingByState = false
        isSearchingByDistance = true
        searchRadiusInMiles = value

        if userHasGivenLocationPermission {
            await fetchNearbyShows()
        } else {
            self.userHasGivenLocationPermission = false
            self.viewState = .dataLoaded
        }
    }

    func addLocationNotificationObserver() {
        NotificationCenter.default.addObserver(forName: .userLocationWasSet, object: nil, queue: .main) {
            if let locationAuthorizationStatus = $0.userInfo?[NotificationConstants.locationPermissionStatus] as? CLAuthorizationStatus {
                Task { @MainActor in
                    self.locationAuthorizationStatus = locationAuthorizationStatus

                    switch locationAuthorizationStatus {
                    case .notDetermined:
                        return
                    case .restricted, .denied:
                        self.userHasGivenLocationPermission = false
                        self.viewState = .dataLoaded
                    case .authorizedAlways, .authorizedWhenInUse:
                        self.userHasGivenLocationPermission = true
                        self.viewState = .dataLoading
                        await self.fetchNearbyShows()
                    @unknown default:
                        print("Unknown location authorizations status provided.")
                    }
                }
            }
        }
    }
}
