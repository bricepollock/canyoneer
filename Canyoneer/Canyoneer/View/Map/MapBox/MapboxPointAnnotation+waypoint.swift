//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

extension PointAnnotation {
    init(coordinate: AnyCoordinate, waypointName: String?) {
        self.init(point: Point(coordinate.asCLObject))
        let image = UIImage(systemName: "pin.fill")!.withTintColor(UIColor(ColorPalette.Color.warning), renderingMode: .alwaysOriginal)
        self.image = .init(image: image, name: "red_pin")
        self.textField = waypointName
        self.iconAnchor = .bottom
    }
}
