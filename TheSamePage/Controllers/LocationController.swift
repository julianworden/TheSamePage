//
//  LocationController.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/14/22.
//

import Contacts
import MapKit
import Foundation

final class LocationController: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationController()
    
    @Published var locationSet = false
    @Published var userLocation: CLLocation?
    @Published var userCoordinates: CLLocationCoordinate2D?
    @Published var userRegion: MKCoordinateRegion?
    
    var locationManager: CLLocationManager?
    
    func startLocationServices() {
        locationManager = CLLocationManager()
            
        if locationManager != nil {
            locationManager!.delegate = self
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied:
            print("You've denied location permission")
        case .restricted:
            print("Your location permissions are restricted")
        case .authorizedAlways, .authorizedWhenInUse:
            userLocation = manager.location
            userCoordinates = manager.location?.coordinate
            
            if let userCoordinates {
                userRegion = MKCoordinateRegion(center: userCoordinates, latitudinalMeters: 0.5, longitudinalMeters: 0.5)
                locationSet = true
            }

            NotificationCenter.default.post(name: .userLocationWasSet, object: nil)
        @unknown default:
            break
        }
    }
}
