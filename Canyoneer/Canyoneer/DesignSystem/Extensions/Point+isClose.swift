//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import MapboxMaps

extension Point {
    func isClose(to point: Point, proximity: Double = 2) -> Bool {
        let precision: Double = 1000
        let selfCloseLat = (self.coordinates.latitude * precision).rounded(.toNearestOrAwayFromZero)
        let selfCloseLong = (self.coordinates.longitude * precision).rounded(.toNearestOrAwayFromZero)
        let pointCloseLat = (point.coordinates.latitude * precision).rounded(.toNearestOrAwayFromZero)
        let pointCloseLong = (point.coordinates.longitude * precision).rounded(.toNearestOrAwayFromZero)
        return abs(selfCloseLat - pointCloseLat) <= proximity && abs(selfCloseLong - pointCloseLong) <= proximity
    }
}
