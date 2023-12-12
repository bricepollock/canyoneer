//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation

/// Fully typed version of Canyon detail representation
class RopeWikiCanyon: RopeWikiCanyonIndex {
    internal enum CodingKeys: String, CodingKey {
        // Copied from RopeWikiCanyonIndex
        case id = "id"
        case name = "name"
        case quality = "quality"
        case monthStringList = "months"
        case technicalRatingString = "technicalRating"
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
        
        // Extension
        case urlString = "url"
        case htmlDescription = "description"
        case geoJson = "geojson"
    }
    
    let urlString: String
    let htmlDescription: String?
    let geoJson: GeoJson?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.urlString = try container.decode(String.self, forKey: CodingKeys.urlString)
        self.htmlDescription = try? container.decode(String.self, forKey: CodingKeys.htmlDescription)
        self.geoJson = try? container.decode(GeoJson.self, forKey: CodingKeys.geoJson)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(quality, forKey: .quality)
        try container.encode(monthStringList, forKey: .monthStringList)
        try container.encode(technicalRatingRaw, forKey: .technicalRatingString)
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
        try container.encode(urlString, forKey: .urlString)
        try container.encode(htmlDescription, forKey: .htmlDescription)
        try container.encode(geoJson, forKey: .geoJson)
    }
        
    /// - Warning: Should only be used in previews and testing, not properly configured for codable
    init(
        id: String = "101",
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
        url: URL? = URL(string: "http://ropewiki.com/Moonflower_Canyon"),
        description: String = "<b>This is a canyon</b>",
        geoWaypoints: [CoordinateFeature] = [],
        geoLines: [CoordinateFeature] = []
    ) {
        self.urlString = url?.absoluteString ?? ""
        self.htmlDescription = description
        self.geoJson = nil
        super.init(
            id: id,
            name: name,
            coordinate: coordinate,
            technicalDifficulty: technicalDifficulty,
            risk: risk,
            timeGrade: timeGrade,
            waterDifficulty: waterDifficulty,
            minRaps: minRaps,
            maxRaps: maxRaps,
            maxRapLength: maxRapLength,
            bestSeasons: bestSeasons,
            permit: permit,
            shuttleDuration: shuttleDuration,
            quality: quality,
            vehicleAccessibility: vehicleAccessibility
        )
    }
}
