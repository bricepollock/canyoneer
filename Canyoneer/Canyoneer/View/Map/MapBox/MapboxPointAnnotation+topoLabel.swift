//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation

extension PointAnnotation {
    init(coordinate: AnyCoordinate, topoName: String?) {
        self.init(point: Point(coordinate.asCLObject))
        self.textField = topoName
        self.iconAnchor = .center
    }
}
