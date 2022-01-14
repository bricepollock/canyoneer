//
//  GPXService.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
//

import Foundation
import CoreGPX

class GPXService {
    func gpxString(from canyon: Canyon) -> String {
        let root = GPXRoot(creator: "Backcountry Nomad")
        
        // map canyon point
        let canyonPoint = GPXWaypoint(latitude: canyon.coordinate.latitude, longitude: canyon.coordinate.longitude)
        canyonPoint.name = canyon.name
        root.add(waypoint: canyonPoint)
        
        // map waypoints
        let waypoints: [GPXWaypoint] = canyon.geoWaypoints.map { feature in
            let waypoint = GPXWaypoint(latitude: feature.coordinates[0].latitude, longitude: feature.coordinates[0].longitude)
            waypoint.name = feature.name
            return waypoint
        }
        root.add(waypoints: waypoints)
        
        // map waypoints
        let routes: [GPXRoute] = canyon.geoLines.map { line in
            let route = GPXRoute()
            route.points = line.coordinates.map { point in GPXRoutePoint(latitude: point.latitude, longitude: point.longitude)}
            route.name = line.name
            return route
        }
        root.add(routes: routes)
        return root.gpx()
    }
    
    func gpxFileUrl(from canyon: Canyon) -> URL? {
        let gpxString = self.gpxString(from: canyon)
        let data = gpxString.data(using: .utf8)
        let fixedName = canyon.name.replacingOccurrences(of: " ", with: "_")
        let url = data?.dataToFile(fileName: "\(fixedName).gpx")
        return url as URL?

    }
}
