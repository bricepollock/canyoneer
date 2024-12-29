//  Created by Brice Pollock for Canyoneer on 3/23/24

import Foundation
import MapboxMaps
import CoreLocation
import UIKit

fileprivate let topoBackgroundColor = UIColor(red: 158/255, green: 203/255, blue: 128/255, alpha: 1)

extension CoordinateFeature {
    /// The color for this line we show on map
    var lineColor: UIColor {
        let type = TopoLineType(string: name)
        let geoColor: UIColor?
        if let stroke = hexColor {
            geoColor = UIColor.hex(stroke)
        } else {
            geoColor = nil
        }
        let lineColor = type == .unknown ? geoColor ?? UIColor(type.color) : UIColor(type.color)
        var finalColor = lineColor
        while finalColor.contrastRatio(with: topoBackgroundColor) < 1.5, let darker = finalColor.darker() {
            if type != .unknown {
                assertionFailure("Our defined colors do not contrast nicely with background map green (see Imlay in Zion for an example)")
            }
            finalColor = darker
        }
        return finalColor
    }
}

extension PolylineAnnotation {
    
    static func makeCanyonLineAnnotation(feature: CoordinateFeature, in canyon: CanyonIndex) -> PolylineAnnotation {
        var annotation = PolylineAnnotation(id: Self.id(for: canyon), lineCoordinates: feature.coordinates.map { $0.asCLObject })
        annotation.lineColor = StyleColor(feature.lineColor)
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
