//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

// Be careful about any adoption of ViewAnnotation as it lists performance issues with 250+ annotation
extension PointAnnotation {
    static func canyonPinId(for canyon: CanyonIndex) -> String {
        return canyonPinPrefix + canyon.id
    }
    
    var canyonId: String? {
        guard id.hasPrefix(Self.canyonPinPrefix) else {
            return nil
        }
        return String(id.dropFirst(Self.canyonPinPrefix.count))
        
    }
    
    static let canyonPinPrefix = "canyon-pin-"
}

