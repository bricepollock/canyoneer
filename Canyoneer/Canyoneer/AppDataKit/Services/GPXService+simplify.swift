//
//  GPXService+simplify.swift
//  Canyoneer
//
//  Created by Brice Pollock on 11/17/23.
//

/// If we need something better use the Douglas Pecker
extension GPXService {
    /// Simplify gpx to reduce memory overhead
    static func simplify(features: [CoordinateFeature]) -> [CoordinateFeature] {
        return features.compactMap {
            CoordinateFeature(
                name: $0.name,
                type: $0.type,
                hexColor: $0.hexColor,
                coordinates: simplify(coordinates: $0.coordinates)
            )
        }
    }
    
    static func simplify(coordinates: [Coordinate]) -> [Coordinate] {
        guard var previousCoordinate: Coordinate = coordinates.first else {
            return coordinates
        }
        
        var consolidatedList = [previousCoordinate]
        coordinates.dropFirst().forEach {
            let distanceFromLast = previousCoordinate.distance(to: $0)
            
            guard distanceFromLast.value > Constants.minimumDistanceBetweencoordinates else {
                return // we drop this Coordinate
            }
            
            consolidatedList.append($0)
            previousCoordinate = $0
        }
        return consolidatedList
    }
    
    enum Constants {
        /// We drop coordinates that are less than this distance between them (meters)
        static let minimumDistanceBetweencoordinates: Double = 1
    }
}
