//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import CoreLocation
import MapboxMaps

// MARK: Visibility
extension MapboxMapViewModel {
    public func isVisible(canyon: CanyonIndex) -> Bool {
        visibleMap.contains(forPoint: canyon.coordinate.asCLObject, wrappedCoordinates: true)
    }
    
    public var visibleCanyonIDs: [String] {
        // Seems really inefficient
        canyonPinManager.annotations
            .compactMap {
                let isVisible = visibleMap.contains(forPoint: $0.point.coordinates.asCLObject, wrappedCoordinates: true)
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

// MARK: Canyon Pins
extension MapboxMapViewModel {
    
    
    public func addAnnotations(for canyons: [CanyonIndex]) {
        let newPins = canyons.map {
            makePointAnnotation(for: $0)
        }
        canyonPinManager.annotations.append(contentsOf: newPins)
    }
    // Consider using data-layers to group things instead of mixing annotation styles?
    // Might be easier
    public func removeAnnotations(for canyonMap: [String: CanyonIndex]) {
        canyonPinManager.annotations.removeAll {
            guard let canyonId = $0.canyonId else {
                return false
            }
            return canyonMap[canyonId] != nil
        }
    }
    
    // Might be used when we adopt ViewAnnotation API
    //    public func deselectCanyons() {
    //        self.mapView.selectedAnnotations.forEach {
    //            self.mapView.deselectAnnotation($0, animated: false)
    //        }
    //    }
}

// MARK: Canyon Lines
extension MapboxMapViewModel {
    public func cachePolylines() {
        cachedPolylines = canyonLineManager.annotations
    }
    
    public func applyCache() {
        canyonLineManager.annotations = cachedPolylines
    }
    
    public func purgePolylineCache() {
        cachedPolylines = []
    }
    
    public func removePolylines(for canyons: [CanyonIndex]) {
        var canyonMap = [String: CanyonIndex]()
        canyons.forEach {
            canyonMap[$0.id] = $0
        }
        canyonPinManager.annotations.removeAll {
            guard let canyonId = $0.canyonId else {
                return false
            }
            return canyonMap[canyonId] != nil
        }
    }
    
    func renderPolylines(for canyons: [Canyon]) {
        canyonLineManager.annotations = canyons.flatMap { canyon in
            canyon.geoLines.map { feature -> PolylineAnnotation in
                PolylineAnnotation(feature: feature, in: canyon.index)
            }
        }
    }
//    
//    private func layers(from canyon: Canyon) -> [TopoLineLayer] {
//        // Get all lines
//        let topoLines = canyon.geoLines
//            .map { feature -> TopoLineOverlay in
//                let overlay = TopoLineOverlay(coordinates: feature.coordinates.map { $0.asCLObject }, count: feature.coordinates.count)
//                overlay.name = feature.name
//                
//                // This color will be overriden by the type.color
//                if let hex = feature.hexColor {
//                    overlay.color = UIColor.hex(hex)
//                }
//                return overlay
//            }
//        
//        // Instead of adding each polyline individually, we group them together to try to get better performance on the map renderer even though its less performant to do this here
//        return TopoLineType.allCases.compactMap { type in
//            let linesForLayer = topoLines.filter { $0.type == type }
//            guard linesForLayer.isEmpty == false else { return nil }
//            return TopoLineLayer(
//                name: type.rawValue,
//                type: type,
//                polylines: linesForLayer
//            )
//        }
//    }
}
