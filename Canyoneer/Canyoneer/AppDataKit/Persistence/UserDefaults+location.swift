//
//  UserPreferencesStorage+location.swift
//  Canyoneer
//
//  Created by Brice Pollock on 12/7/22.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(longitude)
        try container.encode(latitude)
    }
     
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let longitude = try container.decode(CLLocationDegrees.self)
        let latitude = try container.decode(CLLocationDegrees.self)
        self.init(latitude: latitude, longitude: longitude)
    }
}

extension UserDefaults {
    
    fileprivate static let lastCoordinateViewKey = "last_view_coordinate"
    private static let locationStorage = UserPreferencesStorage()
    
    func setLastViewCoordinate(_ coordinate: CLLocationCoordinate2D) {
        Self.locationStorage.set(key: Self.lastCoordinateViewKey, value: coordinate)
    }
    
    var lastViewCoordinate: CLLocationCoordinate2D? {
        Self.locationStorage.get(key: Self.lastCoordinateViewKey)
    }
}
