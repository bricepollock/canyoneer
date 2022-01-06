//
//  Region.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

struct Region {
    let name: String
    let geoLocation: CLLocationCoordinate2D
    let children: [Region]
    let canyons: [Canyon]
}
