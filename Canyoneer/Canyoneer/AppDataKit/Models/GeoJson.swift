//
//  GeoJson.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/12/22.
//

import Foundation

struct GeoJson: Codable {
    internal enum CodingKeys: String, CodingKey {
        case type
        case features
    }
    
    let type: String
    let features: [GeoFeature]
}

struct GeoFeature: Codable {
    internal enum CodingKeys: String, CodingKey {
        case typeRaw = "type"
        case geometry
        case properties
    }
    
    let typeRaw: String // typically just 'Feature'
    let geometry: GeoLocation
    let properties: GeoProperties
}

enum GeoFeatureType: String, Codable {
    case line = "LineString"
    case waypoint = "Point"
    case polygon = "Polygon"
}

struct GeoLocation: Codable {
    internal enum CodingKeys: String, CodingKey {
        case typeRaw = "type"
        case points = "coordinates"
    }
    
    let typeRaw: String
    // points is a union of different array nesting depending on type. See decoder for details.
    let points: [[Double]]
    
    var type: GeoFeatureType? {
        return GeoFeatureType(rawValue: typeRaw)
    }
    
    var coordinates: [Coordinate] {
        return points.map { numberList in
            return Coordinate(latitude: numberList[1], longitude: numberList[0])
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.typeRaw = try container.decode(String.self, forKey: .typeRaw)
        if let pointCoordinates = try? container.decode([Double].self, forKey: .points) {
            self.points = [pointCoordinates]
        } else if let lineCoordinates = try? container.decode([[Double]].self, forKey: .points) {
            self.points = lineCoordinates
        } else if let polygonCoordinates = try? container.decode([[[Double]]].self, forKey: .points) {
            // we aren't messing with polygons for now
            self.points = []
        } else {
            Global.logger.error("Cannot figure out how to decode the coordinates for a GeoLocation")
            self.points = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(typeRaw, forKey: .typeRaw)
        try container.encode(points, forKey: .points)
    }
}

struct GeoProperties: Codable {
    internal enum CodingKeys: String, CodingKey {
        case name
    }
    let name: String?
}
