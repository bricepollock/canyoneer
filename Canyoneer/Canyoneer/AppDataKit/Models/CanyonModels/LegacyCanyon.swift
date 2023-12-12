//
//  Canyon.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

/// The original canyon format, used to transition from prior favorite type to current Canyon type
struct LegacyCanyon: Codable {
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
        case geoWaypoints
        case geoLines
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
    var technicalDifficulty: TechnicalGrade?
    var risk: Risk?
    var timeGrade: TimeGrade?
    var waterDifficulty: WaterGrade?
    var quality: Float // 1-5 stars
    var vehicleAccessibility: Vehicle?
    var description: String // HTML
    var geoWaypoints: [CoordinateFeature]
    var geoLines: [CoordinateFeature]
    
    static func dummy() -> LegacyCanyon {
        return LegacyCanyon(
            id: "102",
            bestSeasons: [.march, .april, .may, .june, .july, .august, .september],
            coordinate: Coordinate(latitude: 1, longitude: 1),
            isRestricted: false,
            maxRapLength: 220,
            name: "Moonflower Canyon",
            numRaps: 2,
            requiresShuttle: false,
            requiresPermit: false,
            ropeWikiURL: URL(string: "http://ropewiki.com/Moonflower_Canyon"),
            technicalDifficulty: .three,
            risk: nil,
            timeGrade: .two,
            waterDifficulty: .a,
            quality: 4.3,
            vehicleAccessibility: Vehicle.passenger,
            description: "<b>This is a canyon</b>",
            geoWaypoints: [],
            geoLines: []
        )
    }
}

extension LegacyCanyon: Identifiable, Equatable {
    static func == (lhs: LegacyCanyon, rhs: LegacyCanyon) -> Bool {
        lhs.id == rhs.id
    }
}
