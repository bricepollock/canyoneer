//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import CoreLocation
import MapboxMaps
import UIKit

extension MapboxMapViewModel {    
    func renderWaypointsAndLineLabels(canyon: Canyon) {        
        // add waypoints from map
        var waypoints: [PointAnnotation] = []
        canyon.geoWaypoints.forEach { feature in
            // all waypoints should have one coordinate
            guard let first = feature.coordinates.first else {
                return
            }
            let point = Point(first.asCLObject)
            
            // avoid any waypoints that overlap with others
            if waypoints.contains(where: { $0.point.coordinates.overlaps(coordinate: point.coordinates) }) == true {
                return
            }
            
            let waypointAnnotation = PointAnnotation.makeWaypointAnnotation(coordinate: first, waypointName: feature.name)
            waypoints.append(waypointAnnotation)
        }
        waypointManager.annotations = waypoints
        
        // if no waypoints throw the canyon on there
        if waypoints.isEmpty {
            self.updateCanyonPins(to: [canyon.index])
        }
        
        // add labels for the lines
        canyonLabelManager.annotations = canyon.geoLines.compactMap { feature -> PointAnnotation? in
            // if couldn't find a coordinate away from waypoints then skip this label
            guard let labelCoordinate = unobstructedPoint(
                on: feature.coordinates.map { $0.asCLObject },
                given: waypoints.map { $0.point.coordinates }
            ) else {
                return nil
            }
            
            return PointAnnotation.makeLabel(feature: feature, coordinate: labelCoordinate)
        }
    }
    
    /// Find an unobstructed location to put the label for the feature, iterating outward from the center
    /// - Note: First tries to find a spaced out location for a clean map (better for longer lines) and then if it fails, just any point that doesn't overlap (best for shorter lines)
    func unobstructedPoint(on line: [CLLocationCoordinate2D], given otherAnnotationCoordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        guard line.isEmpty == false else {
            return nil
        }
        
        // Order from center out
        let lineMiddleOrdered = line.centerSort()
        
        // Find the best coordinate closest to middle but a decent distance from the waypoints
        // - Note: array-middle might not be similar to distance-middle
        for currentLineCoordinate in lineMiddleOrdered {
            if unobstructedPoint(point: currentLineCoordinate, by: otherAnnotationCoordinates, useOverlappingCriteria: false) {
                return currentLineCoordinate
            }
        }
        
        // If couldn't find a coordinate that way, then use more forgiving criteria
        for currentLineCoordinate in lineMiddleOrdered {
            if unobstructedPoint(point: currentLineCoordinate, by: otherAnnotationCoordinates, useOverlappingCriteria: true) {
                return currentLineCoordinate
            }
        }
        
        return nil
    }
    
    /// Whether the `point` is not obstructed by `otherCoordinates`
    /// - Parameter useOverlappingCriteria: Whether to use the more forgiving `overlap` criteria for closenss to determine obstruction
    func unobstructedPoint(point: CLLocationCoordinate2D, by otherCoordinates: [CLLocationCoordinate2D], useOverlappingCriteria: Bool) -> Bool {
        return otherCoordinates.reduce(true) { acc, nextCoordinate in
            if useOverlappingCriteria {
                return acc && !nextCoordinate.overlaps(coordinate: point)
            } else {
                return acc && !nextCoordinate.isClose(to: point)
            }
            
        }
    }
}
