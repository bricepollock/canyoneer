//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

// Consider moving to ViewAnnotation API
extension PointAnnotation {
    init(canyon: CanyonIndex) {
        self.init(id: Self.id(for: canyon), point: Point(canyon.coordinate.asCLObject))
        let image = UIImage(systemName: "pin.fill")!.withTintColor(UIColor(ColorPalette.Color.warning), renderingMode: .alwaysOriginal)
        self.image = .init(image: image, name: "red_pin")
        self.textField = canyon.name
        self.iconAnchor = .bottom
    }
    
    static func id(for canyon: CanyonIndex) -> String {
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
