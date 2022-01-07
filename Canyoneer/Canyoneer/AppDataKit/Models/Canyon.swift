//
//  Canyon.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

struct Canyon {
    let coordinate: CLLocationCoordinate2D
    let maxRapLength: Int? // feet
    let name: String
    let numRaps: Int?
}
