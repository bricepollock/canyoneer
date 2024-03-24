//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import CoreLocation
import MapboxMaps

// All visiblity logic
extension MapboxMapViewModel {
    
    public func visibleCanyonIDs() -> [String] {
        canyonIDs(in: visibleMap)
    }
    
    public func renderAreaCanyonIDs() -> [String] {
        canyonIDs(in: renderingBounds)
    }
    
    private func canyonIDs(in area: CoordinateBounds) -> [String] {
        // Seems really inefficient
        canyonPinManager.annotations
            .compactMap {
                let isVisible = area.contains(forPoint: $0.point.coordinates.asCLObject, wrappedCoordinates: true)
                guard isVisible else {
                    return nil
                }
                return $0.canyonId
                
            }
    }
        
    // Logic doesn't belong here, probably easier with view annotations because they can store the canyon object?
//    public var visibleCanyons: [CanyonIndex] {
//        return self.mapView.visibleAnnotations().compactMap {
//            return ($0 as? CanyonAnnotation)?.canyon
//        }
//    }
    
    // Logic doesn't belong here
//    public var currentCanyons: [CanyonIndex] {
//        return self.mapView.annotations.compactMap {
//            return ($0 as? CanyonAnnotation)?.canyon
//        }
//    }
}


