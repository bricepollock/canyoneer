//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

extension PolylineAnnotation {
    private static let topoBackgroundColor = UIColor(red: 158/255, green: 203/255, blue: 128/255, alpha: 1)
    static func makeCanyonLineAnnotation(feature: CoordinateFeature, in canyon: CanyonIndex) -> PolylineAnnotation {
        var annotation = PolylineAnnotation(id: Self.id(for: canyon), lineCoordinates: feature.coordinates.map { $0.asCLObject })
        let type = TopoLineType(string: feature.name)
        let geoColor: UIColor?
        if let stroke = feature.hexColor {
            geoColor = UIColor.hex(stroke)
        } else {
            geoColor = nil
        }
        let lineColor = type == .unknown ? geoColor ?? UIColor(type.color) : UIColor(type.color)
        let finalColor: UIColor
        if lineColor.contrastRatio(with: topoBackgroundColor) < 1.5, let darker = lineColor.darker() {
            if type != .unknown {
                assertionFailure("Our defined colors do not contrast nicely with background map green (see Imlay in Zion for an example)")
            }
            finalColor = darker
        } else {
            finalColor = lineColor
        }
        annotation.lineColor = StyleColor(finalColor)
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
