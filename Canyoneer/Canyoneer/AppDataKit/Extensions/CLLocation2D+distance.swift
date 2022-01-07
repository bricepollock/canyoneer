//
//  CLLocation2D+distance.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/7/22.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    /// returns distance in miles
    func distance(to anotherLocation: CLLocationCoordinate2D) -> Double {
        let thatLocation = CLLocation(latitude: anotherLocation.latitude, longitude: anotherLocation.longitude)
        return self.distance(to: thatLocation) * 0.000621371 // miles conversion
    }
    
    func distance(to thatLocation: CLLocation) -> Double {
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return thisLocation.distance(from: thatLocation) * 0.000621371 // miles conversion
    }
}
