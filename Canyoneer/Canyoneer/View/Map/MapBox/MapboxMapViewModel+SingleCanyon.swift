//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import CoreLocation
import MapboxMaps

extension MapboxMapViewModel {
    func renderPolylines(for canyon: Canyon) {
        let annotations = canyon.geoLines.map { feature -> PolylineAnnotation in
            PolylineAnnotation(feature: feature, in: canyon.index)
        }
        canyonLineManager.annotations = annotations
    }
    
    func renderWaypoints(canyon: Canyon) {        
        // add waypoints from map
        var waypoints: [PointAnnotation] = []
        canyon.geoWaypoints.forEach { feature in
            // all waypoints should have one coordinate
            guard let first = feature.coordinates.first else {
                return
            }
            let point = Point(first.asCLObject)
            
            // avoid any waypoints that overlap with others
            if waypoints.contains(where: { $0.point.isClose(to: point, proximity: 1) }) == true {
                return
            }
            
            let waypointAnnotation = PointAnnotation(coordinate: first, waypointName: feature.name)
            waypoints.append(waypointAnnotation)
        }
        waypointManager.annotations = waypoints
        
        // if no waypoints throw the canyon on there
        if waypoints.isEmpty {
            let canyonAnnotation = makePointAnnotation(for: canyon.index)
            canyonPinManager.annotations = [canyonAnnotation]
        }
        
        // add labels for the lines
        canyonLabelManager.annotations = canyon.geoLines.compactMap { feature -> PointAnnotation? in
            // find a coordinate away from waypoints to label the polyline
            var coordinates = feature.coordinates
            var first: Coordinate? = coordinates.first
            while let found = first {
                let point = Point(found.asCLObject)
                // if our line coordinate is far from other waypoints, then use it
                if waypoints.contains(where: { $0.point.isClose(to: point) }) == false{
                    break
                }
                coordinates = Array(coordinates.dropFirst())
                first = coordinates.first
            }
            // if couldn't find a coordinate away from waypoints then skip this label
            guard let labelCoordinate = first else {
                return nil
            }
            
            return PointAnnotation(coordinate: labelCoordinate, topoName: feature.name)
        }
    }
}
