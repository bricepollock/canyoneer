//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    /// - Parameter precision: What decimal place to look at for closeness
    /// - Parameter proximity: How close both latitude and longitude must be between points given the precision of this function (0.001)
    func isClose(to coordinate: CLLocationCoordinate2D, precision: Int = 3, proximity: Double = 2) -> Bool {
        // All this `.digits(digits+1)` stuff is because doing basic math is resulting in some error in 10^-14 range
        let tolerance = (proximity / pow(Double(10), Double(precision))).digits(precision+1)
        let latitudeDifference = abs(self.latitude - coordinate.latitude).digits(precision+1)
        let longitudeDifference = abs(self.longitude - coordinate.longitude).digits(precision+1)
        
        return latitudeDifference <= tolerance && longitudeDifference <= tolerance
    }
    
    func overlaps(coordinate: CLLocationCoordinate2D) -> Bool {
        isClose(to: coordinate, precision: 4, proximity: 5)
    }
}
