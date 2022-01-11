//
//  Canyon.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    var asCLObject: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

struct Canyon: Codable {
    internal enum CodingKeys: String, CodingKey {
        case id
        case bestSeasons
        case coordinate
        case isRestricted
        case maxRapLength
        case name
        case numRaps
        case requiresShuttle
        case requiresPermit
        case ropeWikiURL
        case technicalDifficulty
        case timeGrade
        case waterDifficulty
        case quality
        case vehicleAccessibility
    }
    
    let id: String
    let bestSeasons: [Month]
    let coordinate: Coordinate
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
