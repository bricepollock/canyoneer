//  Created by Brice Pollock for Canyoneer on 3/24/24

import Foundation
import CoreLocation
import MapboxMaps

// Handles all rendering of canyon pins
extension MapboxMapViewModel {

    /// - Warning: Not necessarily efficient (See complexity of `compare` method
    /// While a simple-replace is more efficient, it results in some map-flashing where existing lines are removed and then re-adding. This approach, while more complex, results in no-flashing on removal
    public func updateCanyonPins(to new: [CanyonIndex]) {
        Global.logger.debug("Rendering canyons: \(new.count)")
        let comparisonLookup = new.compare(to: canyonPinManager.annotations)
        
        // Add new lines
        let newAnnotations = comparisonLookup.added.values.map {
            makePointAnnotation(for: $0)
        }
        canyonPinManager.annotations.append(contentsOf: newAnnotations)
        
        // Remove old lines
        canyonPinManager.annotations.removeAll {
            guard let canyonID = $0.canyonId else {
                return false
            }
            return comparisonLookup.removed[canyonID] != nil
        }
    }
    
    // Might be used when we adopt ViewAnnotation API
    //    public func deselectCanyons() {
    //        self.mapView.selectedAnnotations.forEach {
    //            self.mapView.deselectAnnotation($0, animated: false)
    //        }
    //    }
    
    internal func makePointAnnotation(for canyon: CanyonIndex) -> PointAnnotation {
        var annotation = PointAnnotation(canyon: canyon)
        annotation.tapHandler = { [weak self] _ in
            self?.didRequestCanyon.send(canyon)
            return true
        }
        return annotation
    }
}
