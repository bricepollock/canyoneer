//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import MapboxMaps

extension Point {
    func isClose(to point: Point, proximity: Double = 2) -> Bool {
        let this = self.coordinates.asCLObject
        let that = point.coordinates.asCLObject
        return this.isClose(to: that, proximity: proximity)
    }
}
