//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

extension PolylineAnnotation {
    static func makeCanyonLineAnnotation(feature: CoordinateFeature, in canyon: CanyonIndex) -> PolylineAnnotation {
        var annotation = PolylineAnnotation(id: Self.id(for: canyon), lineCoordinates: feature.coordinates.map { $0.asCLObject })
        let type = TopoLineType(string: feature.name)
        let geoColor: UIColor?
        if let stroke = feature.hexColor {
            geoColor = UIColor.hex(stroke)
        } else {
            geoColor = nil
        }
        let color = type == .unknown ? geoColor ?? UIColor(type.color) : UIColor(type.color)
        annotation.lineColor = StyleColor(color)
        annotation.lineWidth = 3
        annotation.lineOpacity = 0.5
        return annotation
    }
    
    private static func id(for canyon: CanyonIndex) -> String {
        return "\(canyonLinePrefix).\(canyon.id).\(UUID().uuidString)"
    }
    
    public var canyonId: String? {
        guard let canyonId = id.split(separator: ".")[safe: 2] else {
            return nil
        }
        return String(canyonId)
    }
    
    private static let canyonLinePrefix = "canyon.line"
}
