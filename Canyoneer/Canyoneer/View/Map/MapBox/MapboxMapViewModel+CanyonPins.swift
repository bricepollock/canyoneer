//  Created by Brice Pollock for Canyoneer on 3/24/24

import Foundation
import CoreLocation
import MapboxMaps
import UIKit

// Handles all rendering of canyon pins
extension MapboxMapViewModel {

    /// - Warning: Not necessarily efficient (See complexity of `compare` method
    /// While a simple-replace is more efficient, it results in some map-flashing where existing lines are removed and then re-adding. This approach, while more complex, results in no-flashing on removal
    public func updateCanyonPins(to new: [CanyonIndex]) {
        Global.logger.debug("Rendering canyons: \(new.count)")
        let comparisonLookup = new.compare(to: canyonPinManager.annotations)
        
        // Add new lines
        let newAnnotations = comparisonLookup.added.values.map {
            makePointAnnotation(for: $0, isFavorite: favoriteService.isFavorite(canyon: $0))
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
    
    /// Updates canyon pin imagery with current status (ex: Favorite image changes)
    public func updateCanyonPin(_ canyon: CanyonIndex) {
        // Remove exisiting pin
        canyonPinManager.annotations.removeAll {
            $0.canyonId == canyon.id
        }
        
        // update with new Pin
        canyonPinManager.annotations.append(makePointAnnotation(for: canyon, isFavorite: favoriteService.isFavorite(canyon: canyon)))
    }
    
    func makePointAnnotation(for canyon: CanyonIndex, isFavorite: Bool) -> PointAnnotation {
        var annotation = PointAnnotation.makeCanyonAnnotation(for: canyon, isFavorite: isFavorite)
        annotation.tapHandler = { [weak self] _ in
            self?.didRequestCanyon.send(canyon)
            return true
        }
        return annotation
    }
}
