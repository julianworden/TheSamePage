//
//  HomeViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/17/22.
//

import FirebaseFirestore
import Foundation
import GeoFireUtils

class HomeViewModel: ObservableObject {
    @Published var nearbyShows = [Show]()
    @Published var searchRadiusInMiles = 25.0
    
    var searchRadiusInMeters: Double {
        let milesValue = Measurement(value: searchRadiusInMiles, unit: UnitLength.miles)
        return milesValue.converted(to: UnitLength.meters).value
    }
    
    let db = Firestore.firestore()
    var userCoordinates: CLLocationCoordinate2D?

    func performShowsGeoQuery() async throws {
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
        
        for query in queries {
            do {
                let querySnapshot = try await query.getDocuments()
                Task { @MainActor in
                    nearbyShows = try getShowObjects(withSnapshot: querySnapshot)
                }
            } catch {
                throw error
            }
        }
    }
    
    func getShowObjects(withSnapshot snapshot: QuerySnapshot) throws -> [Show] {
        guard let userCoordinates = self.userCoordinates,
              !snapshot.documents.isEmpty else { return [] }
        
        var fetchedShows = [Show]()
        
        for document in snapshot.documents {
            let show = try document.data(as: Show.self)
            let showLatitude = show.latitude
            let showLongitude = show.longitude
            let showLocation = CLLocation(latitude: showLatitude, longitude: showLongitude)
            let userLocation = CLLocation(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude)
            let distanceBetweenUserAndShow = GFUtils.distance(from: userLocation, to: showLocation)
            
            // Filter out false positives
            if distanceBetweenUserAndShow <= searchRadiusInMeters {
                fetchedShows.append(show)
            }
        }
        
        return fetchedShows
    }
    
    /// Fetches shows closest to the user based on their distance filter settings.
    func getShowsNearYou() {
        nearbyShows = DatabaseService.shared.getShowsNearYou()
    }
}
