//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

// Be careful about any adoption of ViewAnnotation as it lists performance issues with 250+ annotation
extension PointAnnotation {
    // Be careful transforming this to custom initialization method as that caused image not to render for some reason
    static func makeCanyonAnnotation(for canyon: CanyonIndex, isFavorite: Bool) -> PointAnnotation {
        var annotation = PointAnnotation(id: PointAnnotation.canyonPinId(for: canyon), coordinate: canyon.coordinate.asCLObject)

        annotation.image = canyonPinImage(isFavorite: isFavorite)
        annotation.textField = canyon.name
        annotation.textSize = 12
        annotation.textHaloBlur = 2
        annotation.textHaloColor = StyleColor(.white)
        annotation.textOpacity = 100
        annotation.textHaloWidth = 2
        annotation.iconAnchor = .bottom
        annotation.textOffset = [0, 1]
        return annotation
    }
    
    static func canyonPinImage(isFavorite: Bool) -> PointAnnotation.Image {
        if isFavorite {
            return PointAnnotation.Image(image: UIImage(resource: .canyonPinFavorite), name: "canyon_pin_favorite")
        } else {
            return PointAnnotation.Image(image: UIImage(resource: .canyonPin), name: "canyon_pin")
        }
    }
    
    private static func canyonPinId(for canyon: CanyonIndex) -> String {
        return canyonPinPrefix + canyon.id
    }
    
    public var canyonId: String? {
        guard id.hasPrefix(Self.canyonPinPrefix) else {
            return nil
        }
        return String(id.dropFirst(Self.canyonPinPrefix.count))
        
    }
    
    private static let canyonPinPrefix = "canyon-pin-"
}

