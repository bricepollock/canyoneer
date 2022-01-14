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

class TopoLineOverlay: MKPolyline {
    var name: String?
    var type: TopoLineType {
        guard let name = name else { return .unknown }
        return TopoLineType(string: name)
    }
}
