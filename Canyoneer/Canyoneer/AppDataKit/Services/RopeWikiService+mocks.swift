//
//  RopeWikiService+mocks.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    static let zero = CLLocationCoordinate2D(latitude: .zero, longitude: .zero)
}

extension RopeWikiService {
    static let utah = Region(
        name: "Utah",
        geoLocation: .zero,
        children: [
            Region(
                name: "Zion",
                geoLocation: CLLocationCoordinate2D.zero,
                children: [
                    Region(
                        name: "Area 1",
                        geoLocation: CLLocationCoordinate2D.zero,
                        children: [],
                        canyons: []
                    ),
                    Region(
                        name: "Area 2",
                        geoLocation: CLLocationCoordinate2D.zero,
                        children: [],
                        canyons: []
                    )
                ],
                canyons: []
            ),
            Region(
                name: "Moab",
                geoLocation: CLLocationCoordinate2D.zero,
                children: [
                    Region(
                        name: "Area 1",
                        geoLocation: CLLocationCoordinate2D.zero,
                        children: [],
                        canyons: [Self.moonflower]
                    )
                ],
                canyons: []
            )
        ],
        canyons: []
    )
    static let california = Region(
        name: "California",
        geoLocation: CLLocationCoordinate2D.zero,
        children: [
            Region(
                name: "Death Valley",
                geoLocation: CLLocationCoordinate2D.zero,
                children: [
                    Region(
                        name: "Furnace Creek",
                        geoLocation: CLLocationCoordinate2D.zero,
                        children: [],
                        canyons: []
                    )
                ],
                canyons: []
            )
        ],
        canyons: []
    )
    
    static let moonflower = Canyon(
        coordinate: CLLocationCoordinate2D(latitude: 38.5542, longitude: -109.5794),
        maxRapLength: 220,
        name: "Moonflower",
        numRaps: 2
        
        
    )
}
