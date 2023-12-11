//  Created by Brice Pollock for Canyoneer on 12/10/23

import Foundation

struct CoordinateFeature: Codable {
    let name: String?
    let type: GeoFeatureType
    let hexColor: String?
    let coordinates: [Coordinate]
    
    init?(name: String?, type: GeoFeatureType?, hexColor: String?, coordinates: [Coordinate]) {
        guard let type = type else { return nil }
        self.name = name
        self.type = type
        self.hexColor = hexColor
        self.coordinates = coordinates
    }
}
