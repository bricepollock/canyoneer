//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

extension CoordinateFeature {
    /// The text color for the label of this line we show on map
    var labelTextColor: UIColor {
        return .white
    }
    
    /// The background (halo) color for the label of this line we show on map
    /// - Note: May be different than `lineColor` because of contrast between `labelTextColor`
    var labelBackground: UIColor {
        var finalColor = lineColor
        while finalColor.contrastRatio(with: labelTextColor) < 1.5, let darker = finalColor.darker() {
            finalColor = darker
        }
        return finalColor
    }
}

extension PointAnnotation {
    static func makeLabel(feature: CoordinateFeature, coordinate: AnyCoordinate) -> PointAnnotation {
        var annotation = PointAnnotation(coordinate: coordinate.asCLObject)
        annotation.iconAnchor = .center
        annotation.textField = feature.name
        annotation.textHaloBlur = 2
        annotation.textHaloColor = StyleColor(feature.labelBackground)
        annotation.textHaloWidth = 2
        annotation.textOpacity = 100
        annotation.textSize = 12
        annotation.textColor = StyleColor(feature.labelTextColor)
        return annotation
    }
}
