//  Created by Brice Pollock for Canyoneer on 12/29/24

import Foundation

extension Array {
    func centerSort() -> [Element] {
        if isEmpty {
            return []
        }
        let middle = Int(self.count/2)
        return enumerated()
            .sorted { lhs, rhs in
                let lhsDistance =  abs(lhs.offset - middle)
                let rhsDistance =  abs(rhs.offset - middle)
                return lhsDistance < rhsDistance
            }
            .map { idx, val in
                val
            }
    }
}
