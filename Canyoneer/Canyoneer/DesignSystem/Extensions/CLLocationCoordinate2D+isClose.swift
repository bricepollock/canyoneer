//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    func isClose(to coordinate: CLLocationCoordinate2D, proximity: Double = 2) -> Bool {
        let precision: Double = 1000
        let selfCloseLat = (self.latitude * precision).rounded(.toNearestOrAwayFromZero)
        let selfCloseLong = (self.longitude * precision).rounded(.toNearestOrAwayFromZero)
        let pointCloseLat = (coordinate.latitude * precision).rounded(.toNearestOrAwayFromZero)
        let pointCloseLong = (coordinate.longitude * precision).rounded(.toNearestOrAwayFromZero)
        return abs(selfCloseLat - pointCloseLat) <= proximity && abs(selfCloseLong - pointCloseLong) <= proximity
    }
}
