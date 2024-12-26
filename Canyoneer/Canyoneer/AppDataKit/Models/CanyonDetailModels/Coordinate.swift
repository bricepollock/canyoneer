//
//  Coordinate.swift
//  Canyoneer
//
//  Created by Brice Pollock on 11/19/23.
//

import Foundation
import CoreLocation

protocol AnyCoordinate {
    var latitude: CLLocationDegrees { get }
    var longitude: CLLocationDegrees { get }
}

extension AnyCoordinate {
    var asCLObject: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    var asString: String {
        "\(self.latitude.digits(5)), \(self.longitude.digits(5))"
    }
    
    func distance(to coordinate: AnyCoordinate) -> Measurement<UnitLength> {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = from.distance(from: to)
        return Measurement(value: distance, unit: UnitLength.meters)
    }
}

extension CLLocation: AnyCoordinate {
    var latitude: CLLocationDegrees { coordinate.latitude }
    var longitude: CLLocationDegrees { coordinate.longitude }
}

extension CLLocationCoordinate2D: AnyCoordinate {}

class Coordinate: AnyCoordinate, Codable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees

    enum CodingKeys : String, CodingKey {
        case latitude
        case longitude
    }
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
