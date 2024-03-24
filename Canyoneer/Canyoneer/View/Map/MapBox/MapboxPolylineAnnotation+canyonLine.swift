//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

extension PolylineAnnotation {
    init(feature: CoordinateFeature, in canyon: CanyonIndex) {
        self.init(id: Self.id(for: canyon), lineCoordinates: feature.coordinates.map { $0.asCLObject })
        let type = TopoLineType(string: feature.name)
        let geoColor: UIColor?
        if let stroke = feature.hexColor {
            geoColor = UIColor.hex(stroke)
        } else {
            geoColor = nil
        }
        let color = type == .unknown ? geoColor ?? UIColor(type.color) : UIColor(type.color)
        self.lineColor = StyleColor(color)
        self.lineWidth = 3
        self.lineOpacity = 0.5
    }
    
    static func id(for canyon: CanyonIndex) -> String {
        return "\(canyonLinePrefix).\(canyon.id).\(UUID().uuidString)"
    }
    
    var canyonId: String? {
        guard let canyonId = id.split(separator: ".")[safe: 3] else {
            return nil
        }
        return String(canyonId)
    }
    
    static let canyonLinePrefix = "canyon.line"
}
