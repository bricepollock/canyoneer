//
//  Region.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

struct Coordinate {
    let latitude: Float
    let longitude: Float
    
    static let zero = Coordinate(latitude: 0, longitude: 0)
}

struct Region {
    let name: String
    let geoLocation: Coordinate
    let children: [Region]
}
