//
//  MockController.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/8/23.
//

@testable import TheSamePage

import MapKit
import Foundation

/// Sets values for LocationController.shared so that it can easily be used in tests

struct MockController {
    static func setMockLocationControllerValues() {
        let mockLocationController = LocationController.shared
        mockLocationController.userLocation = CLLocation(latitude: 37.329130, longitude: -121.899020)
        mockLocationController.userCoordinates = mockLocationController.userLocation!.coordinate
        mockLocationController.userRegion = MKCoordinateRegion(center: mockLocationController.userCoordinates!, latitudinalMeters: 0.5, longitudinalMeters: 0.5)
        mockLocationController.locationSet = true
    }
}
