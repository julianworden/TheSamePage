//
//  CustomMapAnnotation.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/16/22.
//

import Foundation
import MapKit

class CustomMapAnnotation: NSObject, Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
    
    init(coordinates: CLLocationCoordinate2D) {
        self.coordinate = coordinates
    }
}
