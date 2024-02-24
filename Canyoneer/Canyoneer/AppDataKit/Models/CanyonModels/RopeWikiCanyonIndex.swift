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
        case version
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
    let version: String
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: CodingKeys.id)
        self.name = try container.decode(String.self, forKey: CodingKeys.name)
        self.quality = try? container.decode(Double.self, forKey: CodingKeys.quality)
        self.monthStringList = try? container.decode( [String].self, forKey: CodingKeys.monthStringList)
        self.technicalRatingRaw = try? container.decode(Int.self, forKey: CodingKeys.technicalRatingRaw)
        self.waterRatingString = try? container.decode(String.self, forKey: CodingKeys.waterRatingString)
        self.timeRatingString = try? container.decode(String.self, forKey: CodingKeys.timeRatingString)
        self.riskRatingString = try? container.decode(String.self, forKey: CodingKeys.riskRatingString)
        self.permitString = try? container.decode(String.self, forKey: CodingKeys.permitString)
        self.rappelCountMin = try? container.decode(Int.self, forKey: CodingKeys.rappelCountMin)
        self.rappelCountMax = try? container.decode(Int.self, forKey: CodingKeys.rappelCountMax)
        self.rappelLongestMeters = try? container.decode(Double.self, forKey: CodingKeys.rappelLongestMeters)
        self.vehicleString = try? container.decode(String.self, forKey: CodingKeys.vehicleString)
        self.shuttleInSeconds = try? container.decode(Double.self, forKey: CodingKeys.shuttleInSeconds)
        self.latitude = try container.decode(Double.self, forKey: CodingKeys.latitude)
        self.longitude = try container.decode(Double.self, forKey: CodingKeys.longitude)
        self.version = try container.decode(String.self, forKey: CodingKeys.version)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(quality, forKey: .quality)
        try container.encode(monthStringList, forKey: .monthStringList)
        try container.encode(technicalRatingRaw, forKey: .technicalRatingRaw)
        try container.encode(waterRatingString, forKey: .waterRatingString)
        try container.encode(timeRatingString, forKey: .timeRatingString)
        try container.encode(riskRatingString, forKey: .riskRatingString)
        try container.encode(permitString, forKey: .permitString)
        try container.encode(rappelCountMin, forKey: .rappelCountMin)
        try container.encode(rappelCountMax, forKey: .rappelCountMax)
        try container.encode(rappelLongestMeters, forKey: .rappelLongestMeters)
        try container.encode(vehicleString, forKey: .vehicleString)
        try container.encode(shuttleInSeconds, forKey: .shuttleInSeconds)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(version, forKey: .version)
    }
    
    /// - Warning: Should only be used in previews and testing, not properly configured for codable
    init(
        id: String = String(Int.random(in: (1..<1000))),
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
        vehicleAccessibility: Vehicle? = .passenger,
        version: String = UUID().uuidString
    ) {
        #if TEST
        // All-good to use
        #else
        fatalError("Should not be using this outside of testing")
        #endif
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
        self.version = version
    }
}
