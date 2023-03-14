//
//  MockController.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/8/23.
//

@testable import TheSamePage

import MapKit
import Foundation

/// Sets values for LocationController.shared so that it can easily be used in tests.
struct MockLocationController {
    /// Sets location data in LocationController.shared to the SF MOMA in San Francisco, CA for testing.
    static func setAlaskaMockLocationControllerValues() {
        let mockLocationController = LocationController.shared
        mockLocationController.userLocation = CLLocation(latitude: 61.218056, longitude: -149.900284)
        mockLocationController.userCoordinates = mockLocationController.userLocation!.coordinate
        mockLocationController.userRegion = MKCoordinateRegion(center: mockLocationController.userCoordinates!, latitudinalMeters: 0.5, longitudinalMeters: 0.5)
        mockLocationController.locationSet = true
    }

    /// Sets location data in LocationController.shared to Starland Ballroom in Sayreville, NJ for testing.
    static func setNewJerseyMockLocationControllerValues() {
        let mockLocationController = LocationController.shared
        mockLocationController.userLocation = CLLocation(latitude: 40.4404902, longitude: -74.355283)
        mockLocationController.userCoordinates = mockLocationController.userLocation!.coordinate
        mockLocationController.userRegion = MKCoordinateRegion(center: mockLocationController.userCoordinates!, latitudinalMeters: 0.5, longitudinalMeters: 0.5)
        mockLocationController.locationSet = true
    }
}
