//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

extension PointAnnotation {
    static func makeLabel(coordinate: AnyCoordinate, topoName: String?, topoColor: UIColor) -> PointAnnotation {
        var annotation = PointAnnotation(coordinate: coordinate.asCLObject)
        annotation.iconAnchor = .center
        annotation.textField = topoName
        annotation.textHaloBlur = 2
        annotation.textHaloColor = StyleColor(topoColor)
        annotation.textHaloWidth = 2
        annotation.textOpacity = 100
        annotation.textSize = 12
        annotation.textColor = StyleColor(.white)
        return annotation
    }
}
