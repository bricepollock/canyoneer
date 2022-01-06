//
//  LandingViewModel+mocks.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

extension LandingViewModel {
    static let utah = Region(
        name: "Utah",
        geoLocation: .zero,
        children: [
            Region(
                name: "Zion",
                geoLocation: Coordinate.zero,
                children: [
                    Region(
                        name: "Area 1",
                        geoLocation: Coordinate.zero,
                        children: [],
                        canyons: []
                    ),
                    Region(
                        name: "Area 2",
                        geoLocation: Coordinate.zero,
                        children: [],
                        canyons: []
                    )
                ],
                canyons: []
            ),
            Region(
                name: "Moab",
                geoLocation: Coordinate.zero,
                children: [
                    Region(
                        name: "Area 1",
                        geoLocation: Coordinate.zero,
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
        geoLocation: Coordinate.zero,
        children: [
            Region(
                name: "Death Valley",
                geoLocation: Coordinate.zero,
                children: [
                    Region(
                        name: "Furnace Creek",
                        geoLocation: Coordinate.zero,
                        children: [],
                        canyons: []
                    )
                ],
                canyons: []
            )
        ],
        canyons: []
    )
    
    static let moonflower = Canyon(name: "Moonflower", numRaps: 2, maxRapLength: 220)
}
