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
        case risk
        case timeGrade
        case waterDifficulty
        case quality
        case vehicleAccessibility
        case description
    }
    
    let id: String
    var bestSeasons: [Month]
    var coordinate: Coordinate
    var isRestricted: Bool?
    var maxRapLength: Int? // feet
    var name: String
    var numRaps: Int?
    var requiresShuttle: Bool?
    var requiresPermit: Bool?
    var ropeWikiURL: URL?
    var technicalDifficulty: Int?
    var risk: Risk?
    var timeGrade: String?
    var waterDifficulty: String?
    var quality: Float // 1-5 stars
    var vehicleAccessibility: Vehicle?
    var description: String // HTML
    
    static func dummy() -> Canyon {
        return Canyon(
            id: UUID().uuidString,
            bestSeasons: [.march, .april, .may, .june, .july, .august, .september],
            coordinate: Coordinate(latitude: 1, longitude: 1),
            isRestricted: false,
            maxRapLength: 220,
            name: "Moonflower Canyon",
            numRaps: 2,
            requiresShuttle: false,
            requiresPermit: false,
            ropeWikiURL: URL(string: "http://ropewiki.com/Moonflower_Canyon"),
            technicalDifficulty: 3,
            risk: nil,
            timeGrade: "II",
            waterDifficulty: "A",
            quality: 4.3,
            vehicleAccessibility: Vehicle.passenger,
            description: "<b>This is a canyon</b>"
        )
    }
}
