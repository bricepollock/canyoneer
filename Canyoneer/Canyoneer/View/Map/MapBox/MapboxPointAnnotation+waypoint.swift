//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

extension PointAnnotation {
    // Be careful transforming this to custom initialization method as that caused image not to render for some reason    
    static func makeWaypointAnnotation(coordinate: AnyCoordinate, waypointName: String?) -> PointAnnotation {
        var annotation = PointAnnotation(point: Point(coordinate.asCLObject))
        let image = UIImage(systemName: "pin.fill")!.withTintColor(UIColor(ColorPalette.Color.warning), renderingMode: .alwaysOriginal)
        annotation.image = .init(image: image, name: "red_pin")
        annotation.textField = waypointName
        annotation.iconAnchor = .bottom
        return annotation
    }
}
