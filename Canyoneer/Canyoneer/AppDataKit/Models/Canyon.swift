//
//  Canyon.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation
import MapKit

struct CoordinateFeature: Codable {
    let name: String?
    let type: GeoFeatureType
    let hexColor: String?
    let coordinates: [Coordinate]
    
    init?(name: String?, type: GeoFeatureType?, hexColor: String?, coordinates: [Coordinate]) {
        guard let type = type else { return nil }
        self.name = name
        self.type = type
        self.hexColor = hexColor
        self.coordinates = coordinates
    }
}

enum TechnicalGrade: Int, CaseIterable, Codable, Equatable {
    case one
    case two
    case three
    case four
    
    var text: String {
        switch self {
        case .one: return "1"
        case .two: return "2"
        case .three: return "3"
        case .four: return "4"
        }
    }
    
    init?(text: String) {
        guard let found = TechnicalGrade.allCases.first(where: { $0.text == text }) else {
            return nil
        }
        self = found
    }
    
    init?(data: Int?) {
        guard let data else { return nil }
        guard let found = TechnicalGrade(rawValue: data) else {
            return nil
        }
        self = found
    }
}

enum WaterGrade: String, CaseIterable, Codable, Equatable {
    case a = "A"
    case b = "B"
    case c = "C"
    
    var text: String {
        self.rawValue
    }
    
    init?(data: String?) {
        guard let data else { return nil }
        guard let found = WaterGrade(rawValue: data) else {
            return nil
        }
        self = found
    }
}

enum TimeGrade: String, CaseIterable, Codable, Equatable {
    case one = "I"
    case two = "II"
    case three = "III"
    case four = "IV"
    case five = "V"
    case six = "VI"
    
    var text: String {
        self.rawValue
    }
    
    var number: Int {
        switch self {
        case .one: return 1
        case .two: return 2
        case .three: return 3
        case .four: return 4
        case .five: return 5
        case .six: return 6
        }
    }
    
    init?(data: String?) {
        guard let data else { return nil }
        guard let found = TimeGrade(rawValue: data) else {
            return nil
        }
        self = found
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

extension Canyon: Identifiable, Equatable {
    static func == (lhs: Canyon, rhs: Canyon) -> Bool {
        lhs.id == rhs.id
    }
}
