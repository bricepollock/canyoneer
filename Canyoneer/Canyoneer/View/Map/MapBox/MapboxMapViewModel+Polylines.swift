//  Created by Brice Pollock for Canyoneer on 3/24/24

import Foundation
import CoreLocation
import MapboxMaps

// All polyline logic
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
    
    func removeAllPolylines() {
        canyonLineManager.annotations = []
    }
    
    /// - Warning: Not necessarily efficient (See complexity of `compare` method
    /// While a simple-replace is more efficient, it results in some map-flashing where existing lines are removed and then re-adding. This approach, while more complex, results in no-flashing on removal
    func updatePolylines(to canyons: [Canyon]) {
        let comparisonLookup = canyons.compare(to: canyonLineManager.annotations)
        
        // Add new lines
        let newAnnotations = comparisonLookup.added.values.flatMap { canyon in
            canyon.geoLines.map { feature -> PolylineAnnotation in
                PolylineAnnotation(feature: feature, in: canyon.index)
            }
        }
        canyonLineManager.annotations.append(contentsOf: newAnnotations)
        
        // Remove old lines
        canyonLineManager.annotations.removeAll {
            guard let canyonID = $0.canyonId else {
                return false
            }
            return comparisonLookup.removed[canyonID] != nil
        }
    }
}
