//  Created by Brice Pollock for Canyoneer on 12/25/24

import Foundation

extension Double {
    func digits(_ numDigits: Int) -> Double {
        guard numDigits > 0 else {
            return self.rounded(.toNearestOrAwayFromZero)
        }
        
        let precision = pow(Double(10), Double(numDigits))
        return (self * precision).rounded(.toNearestOrAwayFromZero) / precision
    }
}
