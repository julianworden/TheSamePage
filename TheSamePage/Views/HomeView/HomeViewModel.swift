//
//  HomeViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/17/22.
//

import FirebaseFirestore
import Foundation
import GeoFireUtils

@MainActor
class HomeViewModel: ObservableObject {
    enum HomeViewModelError: Error {
        case locationController(message: String)
    }
    
    @Published var nearbyShows = [Show]()
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
    
    func performShowsGeoQuery() async {
        guard let userCoordinates = LocationController.shared.userCoordinates else { return }
        
        self.userCoordinates = userCoordinates
        
        let queryBounds = GFUtils.queryBounds(forLocation: userCoordinates,
                                              withRadius: searchRadiusInMeters)
        
        let queries = queryBounds.map { bound -> Query in
            return db.collection("shows")
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        
        var filteredShows = [Show]()
        
        for query in queries {
            do {
                let querySnapshot = try await query.getDocuments()
                guard !querySnapshot.documents.isEmpty else { continue }
                
                for document in querySnapshot.documents {
                    do {
                        // Filter out retrieved documents that aren't Show objects (for some reason non Show documents can get fetched)
                        let show = try document.data(as: Show.self)
                        if let filteredShow = try checkForFalsePositive(withShow: show) {
                            filteredShows.append(filteredShow)
                        }
                    } catch {
                        continue
                    }
                }
            } catch {
                state = .error(message: "Failed to perform GeoQuery in HomeViewModel.performShowsGeoQuery()")
            }
        }
        
        if filteredShows.isEmpty {
            state = .dataNotFound
        } else {
            nearbyShows = [Show]()
            nearbyShows = filteredShows
        }
    }
    
    func checkForFalsePositive(withShow show: Show) throws -> Show? {
        guard let userCoordinates = self.userCoordinates else {
            state = .error(message: "User location not available in HomeViewModel.checkForFalsePositive(withShow:)")
            throw HomeViewModelError.locationController(message: "User location not available in HomeViewModel.checkForFalsePositive(withShow:)")
        }
        
        let showLatitude = show.latitude
        let showLongitude = show.longitude
        let showLocation = CLLocation(latitude: showLatitude, longitude: showLongitude)
        let userLocation = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
        let distanceBetweenUserAndShow = GFUtils.distance(from: userLocation, to: showLocation)
        
        // Filter out false positives
        if distanceBetweenUserAndShow <= searchRadiusInMeters {
            state = .dataLoaded
            return show
        }
        
        return nil
    }
    
    func changeSearchRadius(toValue value: Double) {
        state = .dataLoading
        searchRadiusInMiles = value
        Task {
            await performShowsGeoQuery()
        }
    }
}
