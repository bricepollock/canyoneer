//
//  CanyonPoint.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/6/22.
//

import Foundation

enum Month: String, Codable, CaseIterable, Equatable {
    case january = "January"
    case february = "Feburary"
    case march = "March"
    case april = "April"
    case may = "May"
    case june = "June"
    case july = "July"
    case august = "August"
    case september = "September"
    case october = "October"
    case november = "November"
    case december = "December"
    
    init?(short: String) {
        if let result =  Self.allCases.filter({ $0.short == short }).first {
            self = result
        } else {
            return nil
        }
    }
    
    var initial: String {
        return String(self.rawValue.prefix(1))
    }
    
    var short: String {
        return String(self.rawValue.prefix(3))
    }
}

enum Vehicle: String, Codable {
    case passenger = "Passenger"
    case highClearance = "High Clearance"
    case fourWheels = "4WD"
    case fourWheelsHighClearnace = "4WD - High Clearance"
}

enum Risk: String, Codable {
    case pg = "PG"
    case r = "R"
    case x = "X"
}

struct CanyonDataPoint: Codable {
    internal enum CodingKeys: String, CodingKey {
        case urlString = "URL"
        case name = "Name"
        case quality = "Quality"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case bestSeasonStrings = "Months"
        case difficulty = "Difficulty"
        case riskRaw = "AdditionalRisk"
        case vehicleAccessibilityRaw = "Vehicle"
        case shuttleString = "Shuttle"
        case requirePermitsString = "Permits"
        case timeRatingString = "Time"
        case numRappels = "RappelCountMax"
        case rappelMaxLength = "RappelLengthMax"
        case htmlDescription = "HTMLDescription"
        case geoJson = "GeoJSON"
    }
    
    let urlString: String
    let name: String
    let quality: Float // 1-5
    let latitude: Double?
    let longitude: Double?
    let bestSeasonStrings: [String]
    
    // Optional values are because sometimes the field is not present in the JSON
    let difficulty: String? // Technical and water rating
    let riskRaw: String?
    let vehicleAccessibilityRaw: String?
    let shuttleString: String
    let requirePermitsString: String
    let timeRatingString: String?
    
    // Clearly have null values when not available
    let numRappels: Int?
    let rappelMaxLength: Int?
    let htmlDescription: String?
    
    let geoJson: GeoJson?
    
    // There are string errors like mispelling months so we may miss some months by doing this
    var bestSeasons: [Month] {
        self.bestSeasonStrings.compactMap {
            return Month(rawValue: $0)
        }
    }
    
    var technicalDifficulty: Int? {
        guard let difficulty = difficulty else {
            return nil
        }
        guard difficulty.count == 2 else {
            // "class 2" and "class 3"
            return 2
        }
        return Int(difficulty.prefix(1))
    }
    
    var risk: Risk? {
        guard let riskRaw = riskRaw else {
            return nil
        }
        return Risk(rawValue: riskRaw)
    }
    
    var waterDifficulty: String? {
        guard let difficulty = difficulty else {
            return nil
        }
        guard difficulty.count == 2 else {
            // "class 2" and "class 3"
            return "A"
        }
        
        return String(difficulty.suffix(1)).uppercased()
    }
    
    var vehicleAccessibility: Vehicle? {
        guard let vehicle = vehicleAccessibilityRaw else { return nil }
        return Vehicle(rawValue: vehicle)
    }
    
    var requiresShuttle: Bool? {
        guard !shuttleString.isEmpty && shuttleString != "None" else {
            return nil
        }
        return shuttleString.contains("Required")
    }
    
    var shuttleDetails: String? {
        guard !shuttleString.isEmpty && shuttleString != "None" else {
            return nil
        }
        return shuttleString
    }
    
    var requiresPermits: Bool? {
        guard requirePermitsString.isEmpty == false else {
            return nil
        }
        return requirePermitsString.lowercased().contains("permit required")
    }
    
    var isRestricted: Bool? {
        guard requirePermitsString.isEmpty == false else {
            return nil
        }
        return requirePermitsString.lowercased().contains("access is Restricted")
    }
    
    var isClosed: Bool {
        return requirePermitsString.lowercased().contains("closed to entry")        
    }
}
