//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation

/// Fully typed version of Canyon index representation
struct CanyonIndex: CanyonPreview {
    let id: String
    let name: String
    let coordinate: Coordinate
    
    let technicalDifficulty: TechnicalGrade?
    let risk: Risk?
    let timeGrade: TimeGrade?
    let waterDifficulty: WaterGrade?
    let minRaps: Int?
    let maxRaps: Int?
    let maxRapLength: Measurement<UnitLength>?
    let bestSeasons: [Month]
    let permit: Permit?
    let shuttleDuration: Measurement<UnitDuration>?
    let quality: Double
    let vehicleAccessibility: Vehicle?
    
    /// This data in its codable form
    let asCodable: Codable
    
    init(data: CanyonIndexData) {
        self.id = String(data.id)
        self.name = data.name
        self.coordinate = Coordinate(latitude: data.latitude, longitude: data.longitude)
        
        self.technicalDifficulty = data.technicalRating
        self.risk = data.riskRating
        self.timeGrade = data.timeRating
        self.waterDifficulty = data.waterRating
        self.minRaps = data.rappelCountMin
        self.maxRaps = data.rappelCountMax
        
        if let rappelLongestMeters = data.rappelLongestMeters {
            self.maxRapLength = Measurement(value: rappelLongestMeters, unit: .meters)
        } else {
            self.maxRapLength = nil
        }
        
        self.bestSeasons = data.bestMonths
        self.permit = data.permit
        
        if let shuttleInSeconds = data.shuttleInSeconds {
            self.shuttleDuration = Measurement(value: shuttleInSeconds, unit: UnitDuration.seconds)
        } else {
            self.shuttleDuration = nil
        }
        
        self.quality = data.quality ?? 0
        self.vehicleAccessibility = data.vehicleAccessibility
        
        asCodable = data
    }
    
    /// - Warning: Should only be used in previews and testing, not properly configured for codable
    init(
        id: String = UUID().uuidString,
        name: String = "Moonflower Canyon",
        coordinate: Coordinate = Coordinate(latitude: 1, longitude: 1),
        technicalDifficulty: TechnicalGrade? = .three,
        risk: Risk? = nil,
        timeGrade: TimeGrade? = .two,
        waterDifficulty: WaterGrade? = .a,
        minRaps: Int? = 2,
        maxRaps: Int? = 2,
        maxRapLength: Measurement<UnitLength>? = Measurement(value: 67.056, unit: .meters),
        bestSeasons: [Month] = [.march, .april, .may, .june, .july, .august, .september],
        permit: Permit? = nil,
        shuttleDuration: Measurement<UnitDuration>? = nil,
        quality: Double = 4.3,
        vehicleAccessibility: Vehicle? = .passenger
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.technicalDifficulty = technicalDifficulty
        self.risk = risk
        self.timeGrade = timeGrade
        self.waterDifficulty = waterDifficulty
        self.minRaps = minRaps
        self.maxRaps = maxRaps
        self.maxRapLength = maxRapLength
        self.bestSeasons = bestSeasons
        self.permit = permit
        self.shuttleDuration = shuttleDuration
        self.quality = quality
        self.vehicleAccessibility = vehicleAccessibility
        
        // Basic opt-out since this is supposed to be used for non-production
        self.asCodable = ""
    }
}

extension CanyonIndex {
    static func == (lhs: CanyonIndex, rhs: CanyonIndex) -> Bool {
        lhs.id == rhs.id
    }
}
