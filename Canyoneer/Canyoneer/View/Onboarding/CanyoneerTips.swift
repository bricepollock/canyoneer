//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import TipKit

enum CanyoneerTips: String, Identifiable, Tip {
    case downloadFavorites
    case mapFilter
    case saveGPX
    case seeCanyonOnMap
    
    var id: String {
        rawValue
    }
    
    var title: Text {
        switch self {
        case .downloadFavorites:
            Text("Download Favorites")
        case .mapFilter:
            Text("Filter Canyons")
        case .saveGPX:
            Text("Export GPX")
        case .seeCanyonOnMap:
            Text("View Full Canyon Details")
        }
    }
    
    var message: Text? {
        switch self {
        case .downloadFavorites:
            Text("Download your favorite list to also download the topographic maps around these canyons")
        case .mapFilter:
            Text("Filter canyons on the map according to your preferences")
        case .saveGPX:
            Text("Export the GPX for this canyon to another mapping application on your phone like onX, Gaia, etc.")
        case .seeCanyonOnMap:
            Text("View all GPX lines and waypoints with their names for only this canyon")
        }
    }

    /// Only show tips one time
    var options: [Option] {
        MaxDisplayCount(1)
    }
}
