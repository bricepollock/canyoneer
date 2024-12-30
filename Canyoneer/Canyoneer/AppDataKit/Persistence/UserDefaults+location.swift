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

struct Viewport: Codable {
    let center: CLLocationCoordinate2D
    let zoomLevel: CGFloat
}

extension UserDefaults {
    
    /// - Warning: No longer used. Capture zoom level in addition to coordinate now.
    fileprivate static let legacyLastCoordinateViewKey = "last_view_coordinate"
    
    fileprivate static let lastViewportKey = "last_viewport"
    private static let locationStorage = UserPreferencesStorage()
    
    func setLastViewport(_ viewport: Viewport) {
        Self.locationStorage.set(key: Self.lastViewportKey, value: viewport)
    }
    
    var lastViewport: Viewport? {
        if let lastViewport: Viewport = Self.locationStorage.get(key: Self.lastViewportKey) {
            return lastViewport
        // Legacy Migration. Can be removed in March 2025
        } else if let lastCenter: CLLocationCoordinate2D = Self.locationStorage.get(key: Self.legacyLastCoordinateViewKey) {
            Self.locationStorage.remove(key: Self.legacyLastCoordinateViewKey)
            return Viewport(center: lastCenter, zoomLevel: 8)
        } else {
            return nil
        }
    }
}
