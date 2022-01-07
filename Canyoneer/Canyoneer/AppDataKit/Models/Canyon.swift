//
//  Canyon.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

struct Canyon {
    let bestSeasons: [Month]
    let coordinate: CLLocationCoordinate2D
    let isRestricted: Bool?
    let maxRapLength: Int? // feet
    let name: String
    let numRaps: Int?
    let requiresShuttle: Bool?
    let requiresPermit: Bool?
    let ropeWikiURL: URL?
    let technicalDifficulty: Int?
    let timeGrade: String?
    let waterDifficulty: String?
    let quality: Float // 1-5 stars
    let vehicleAccessibility: Vehicle?
    
}
