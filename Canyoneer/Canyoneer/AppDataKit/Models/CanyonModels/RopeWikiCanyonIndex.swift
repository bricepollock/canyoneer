//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation

class RopeWikiCanyonIndex: CanyonIndexData, Codable {
    internal enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case quality = "quality"
        case monthStringList = "months"
        case technicalRatingRaw = "technicalRating"
        case waterRatingString = "waterRating"
        case timeRatingString = "timeRating"
        case riskRatingString = "riskRating"
        case permitString = "permit"
        case rappelCountMin = "rappelCountMin"
        case rappelCountMax = "rappelCountMax"
        case rappelLongestMeters = "rappelLongestMeters"
        case vehicleString = "vehicle"
        case shuttleInSeconds = "shuttleSeconds"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    let id: Int
    let name: String
    let quality: Double?
    let monthStringList: [String]?
    let technicalRatingRaw: Int?
    let waterRatingString: String?
    let timeRatingString: String?
    let riskRatingString: String?
    let permitString: String?
    let rappelCountMin: Int?
    let rappelCountMax: Int?
    let rappelLongestMeters: Double?
    let vehicleString: String?
    let shuttleInSeconds: Double?
    let latitude: Double
    let longitude: Double
    
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
        guard let mappedID = Int(id) else {
            fatalError("ID Translation error")
        }
        self.id = mappedID
        self.name = name
        self.technicalRatingRaw = technicalDifficulty?.rawValue
        self.waterRatingString = waterDifficulty?.rawValue
        self.timeRatingString = timeGrade?.rawValue
        self.riskRatingString = risk?.rawValue
        self.rappelCountMin = minRaps
        self.rappelCountMax = maxRaps
        self.rappelLongestMeters = maxRapLength?.value
        self.monthStringList = bestSeasons.map { $0.short }
        self.permitString = permit?.rawValue
        self.shuttleInSeconds = shuttleDuration?.value
        self.quality = quality
        self.vehicleString = vehicleAccessibility?.rawValue
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
