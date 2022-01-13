//
//  MKObjects.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/13/22.
//

import Foundation
import MapKit
import CoreLocation

class CanyonAnnotation: MKPointAnnotation {
    public let canyon: Canyon
    
    init(canyon: Canyon) {
        self.canyon = canyon
        super.init()
        self.title = canyon.name
        self.coordinate = canyon.coordinate.asCLObject
    }
}

class WaypointAnnotation: MKPointAnnotation {
    init(feature: CoordinateFeature) {
        super.init()
        self.title = feature.name
        self.coordinate = feature.coordinates[0].asCLObject
    }
}

enum TopoLineType {
    case driving
    case approach
    case descent
    case exit
    
    var color: UIColor {
        switch self {
        case .driving: return ColorPalette.Color.action
        case .approach: return ColorPalette.Color.green
        case .descent: return ColorPalette.Color.warning
        case .exit: return ColorPalette.Color.yellow
        }
    }
}

class TopoLineOverlay: MKPolyline {
    var name: String?
    var type: TopoLineType? {
        guard let name = name else { return nil }
        if name.lowercased().contains("approach") {
            return .approach
        } else if name.lowercased().contains("drive") || name.lowercased().contains("shuttle") {
            return .driving
        } else if name.lowercased().contains("descent") {
            return .descent
        } else if name.lowercased().contains("exit") {
            return .exit
        } else {
            return nil
        }
    }
}
