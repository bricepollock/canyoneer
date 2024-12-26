//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    /// - Parameter proximity: How close both latitude and longitude must be between points given the precision of this function (0.001)
    func isClose(to coordinate: CLLocationCoordinate2D, proximity: Double = 2) -> Bool {
        let digits = 3
        
        // All this `.digits(digits+1)` stuff is because doing basic math is resulting in some error in 10^-14 range
        let tolerance = (proximity / pow(Double(10), Double(digits))).digits(digits+1)
        let latitudeDifference = abs(self.latitude - coordinate.latitude).digits(digits+1)
        let longitudeDifference = abs(self.longitude - coordinate.longitude).digits(digits+1)
        return latitudeDifference <= tolerance && longitudeDifference <= tolerance
    }
}
