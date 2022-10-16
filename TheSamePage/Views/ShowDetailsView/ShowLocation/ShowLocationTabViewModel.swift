//
//  ShowLocationTabViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/16/22.
//

import MapKit
import Foundation

class ShowLocationTabViewModel: ObservableObject {
    let showCoordinates: CLLocationCoordinate2D
    let showAddress: String
    let addressIsVisibleToUser: Bool
    let showDistanceFromUser: String?
    let showVenue: String
    
    var mapAnnotations: [CustomMapAnnotation] {
        let venue = CustomMapAnnotation(coordinates: showCoordinates)
        return [venue]
    }
    
    init(show: Show) {
        self.showCoordinates = show.coordinates
        self.showAddress = show.address
        self.addressIsVisibleToUser = show.addressIsVisibleToUser
        self.showDistanceFromUser = show.distanceFromUser
        self.showVenue = show.venue
    }
    
    func showDirectionsInMaps() {
        let showPlacemark = MKPlacemark(coordinate: showCoordinates)
        let showMapItem = MKMapItem(placemark: showPlacemark)
        showMapItem.name = showVenue
        
        showMapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
    }
}
