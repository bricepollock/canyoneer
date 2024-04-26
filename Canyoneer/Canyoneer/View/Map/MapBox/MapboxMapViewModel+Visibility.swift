//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation

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
}


