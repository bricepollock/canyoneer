//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation

extension PointAnnotation {
    static func makeLabel(coordinate: AnyCoordinate, topoName: String?) -> PointAnnotation {
        var annotation = PointAnnotation(coordinate: coordinate.asCLObject)
        annotation.iconAnchor = .center
        return annotation
    }
}
