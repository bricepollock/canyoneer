//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation

/// Fully typed version of Canyon detail representation
class RopeWikiCanyon: RopeWikiCanyonIndex {
    internal enum CodingKeys: String, CodingKey {
        case htmlDescription = "description"
        case geoJson = "geojson"
    }
    
    let htmlDescription: String?
    let geoJson: GeoJson?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.htmlDescription = try? container.decode(String.self, forKey: CodingKeys.htmlDescription)
        self.geoJson = try? container.decode(GeoJson.self, forKey: CodingKeys.geoJson)
        // RopeWikiCanyonIndex
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Added for RopeWikiCanyon
        try container.encode(htmlDescription, forKey: .htmlDescription)
        try container.encode(geoJson, forKey: .geoJson)
        
        // RopeWikiCanyonIndex
        try super.encode(to: encoder)
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
        urlString: String = "http://ropewiki.com/Moonflower_Canyon",
        description: String = "<b>This is a canyon</b>",
        geoWaypoints: [CoordinateFeature] = [],
        geoLines: [CoordinateFeature] = []
    ) {
        #if TEST
        // All-good to use
        #else
        fatalError("Should not be using this outside of testing")
        #endif
        self.htmlDescription = description
        self.geoJson = nil
        super.init(
            id: id,
            name: name,
            urlString: urlString,
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
