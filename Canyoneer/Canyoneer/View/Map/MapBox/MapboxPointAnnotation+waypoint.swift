//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

extension PointAnnotation {
    // Be careful transforming this to custom initialization method as that caused image not to render for some reason    
    static func makeWaypointAnnotation(coordinate: AnyCoordinate, waypointName: String?) -> PointAnnotation {
        var annotation = PointAnnotation(point: Point(coordinate.asCLObject))
        
        let image = UIImage(named: "info_pin")!
        annotation.image = PointAnnotation.Image(image: image, name: "info_pin")
        annotation.textField = waypointName
        annotation.iconAnchor = .bottom
        annotation.textSize = 12
        annotation.textOffset = [0, 1]
        return annotation
    }
}
