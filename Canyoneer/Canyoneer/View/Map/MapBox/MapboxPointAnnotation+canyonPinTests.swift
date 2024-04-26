//  Created by Brice Pollock for Canyoneer on 2/18/24

import Foundation
import XCTest
import MapboxMaps
@testable import Canyoneer

@MainActor
class PointAnnotation_canyonPin: XCTestCase {
    func testIDCodeDecode() {
        let canyon = CanyonIndex()
        let annotation = PointAnnotation.makeCanyonAnnotation(for: canyon)
        XCTAssertEqual(annotation.canyonId, canyon.id)
        XCTAssertEqual(annotation.textField, canyon.name)
    }
}
